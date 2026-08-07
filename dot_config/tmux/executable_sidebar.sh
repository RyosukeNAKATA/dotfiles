#!/bin/sh
# サイドバーペインの生成・破棄・トグル・幅ピン・自動退避を担うディスパッチャ。
# tmux のフック (session-created / after-new-window / client-resized など) と
# キーバインド (prefix+b / prefix+B) から各サブコマンドを呼ぶ。
#
# 状態を持つグローバルオプション:
#   @sidebar_width    サイドバー幅 (既定 36)
#   @sidebar_min_cols これ未満の端末幅では自動退避 (既定 100)
#   @sidebar_enabled  ユーザーの意思 (1=出す / 0=消す)。prefix+b で反転
#   @sidebar_shown    実際に表示中か (自動退避で 0 になる)。ステータスバーの分岐に使う
#   @sidebar_expand   0=現在セッションのみ展開 / 1=全セッション展開。prefix+B で反転

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RENDER="$DIR/sidebar-render.sh"

opt() { v=$(tmux show -gqv "$1" 2>/dev/null); [ -n "$v" ] && printf '%s' "$v" || printf '%s' "$2"; }

width()    { opt @sidebar_width 36; }
min_cols() { opt @sidebar_min_cols 100; }
enabled()  { [ "$(opt @sidebar_enabled 1)" = "1" ]; }

# 指定ウィンドウ内のサイドバーペイン ID (無ければ空)
sb_pane_in() {
  tmux list-panes -t "$1" -F '#{@sidebar} #{pane_id}' 2>/dev/null |
    awk '$1=="1"{print $2; exit}'
}

# ウィンドウ左端にサイドバーを 1 枚生成する (フォーカスは動かさない)
create() {
  win="$1"
  [ -n "$(sb_pane_in "$win")" ] && return 0            # 既にあれば何もしない
  w=$(width)
  # -f: アクティブペインではなくウィンドウ全体に対して分割する。これにより
  # 既にペイン分割済みのウィンドウでもサイドバーが左端の全高カラムになる。
  p=$(tmux split-window -fhb -l "$w" -d -P -F '#{pane_id}' -t "$win" "exec $RENDER" 2>/dev/null) || return 0
  tmux set -p -t "$p" @sidebar 1 2>/dev/null
  tmux resize-pane -x "$w" -t "$p" 2>/dev/null
}

# 指定ウィンドウのサイドバーを閉じる
kill_win() {
  p=$(sb_pane_in "$1")
  [ -n "$p" ] && tmux kill-pane -t "$p" 2>/dev/null
}

# 全ウィンドウのサイドバーを閉じる
kill_all() {
  tmux list-panes -a -F '#{@sidebar} #{pane_id}' 2>/dev/null |
    awk '$1=="1"{print $2}' |
    while IFS= read -r p; do tmux kill-pane -t "$p" 2>/dev/null; done
}

# 作業ペイン (サイドバー以外) を全て閉じたウィンドウを丸ごと閉じる。
# tmux はペインが 1 枚でも残っていればウィンドウを保持するため、常駐する
# サイドバーが最後の作業ペインを閉じた後もウィンドウを生かし続けてしまう
# (サイドバーだけのゴーストウィンドウ)。pane-exited / window-pane-changed
# フックからこれを呼び、サイドバーしか残っていないウィンドウだけを閉じる。
# サイドバーが 1 枚以上 かつ 作業ペインが 0 のときだけ動く冪等処理なので、
# 通常のウィンドウやペイン切替で誤って呼ばれても何もしない。
prune() {
  win="$1"
  [ -z "$win" ] && return 0
  # 各ペインを sb / work のどちらかへ必ず分類する。#{@sidebar} を直接使うと
  # 作業ペインは空文字 (空行) になり、grep -c . が空行を数えないため作業ペイン数が
  # 常に 0 と誤判定される (= 分割やペイン移動のたびにウィンドウを誤って殺す)。
  # 条件フォーマットで全ペインに非空トークンを出させてこれを回避する。
  panes=$(tmux list-panes -t "$win" -F '#{?@sidebar,sb,work}' 2>/dev/null)
  [ -z "$panes" ] && return 0                                  # ウィンドウが既に無い
  sb=$(printf '%s\n'   "$panes" | grep -c '^sb$')             # サイドバー枚数
  work=$(printf '%s\n' "$panes" | grep -c '^work$')           # 作業ペイン枚数
  [ "$sb" -ge 1 ] && [ "$work" -eq 0 ] && tmux kill-window -t "$win" 2>/dev/null
  return 0
}

# 全ウィンドウを走査してゴーストウィンドウを一掃する (設定読み込み時の掃除用)
prune_all() {
  tmux list-windows -a -F '#{window_id}' 2>/dev/null |
    while IFS= read -r w; do prune "$w"; done
}

# 1 ウィンドウに (条件を満たせば) サイドバーを用意する
ensure_win() {
  enabled || return 0
  win="$1"
  ww=$(tmux display -p -t "$win" '#{window_width}' 2>/dev/null)
  [ -n "$ww" ] && [ "$ww" -lt "$(min_cols)" ] && return 0    # 狭いウィンドウには出さない
  create "$win"
}

# 全ウィンドウにサイドバーを用意する
ensure_all() {
  enabled || return 0
  tmux list-windows -a -F '#{window_id}' 2>/dev/null |
    while IFS= read -r w; do ensure_win "$w"; done
  tmux set -g @sidebar_shown 1 2>/dev/null
}

# 全ウィンドウのサイドバーを一括で作り直す (kill-all → ensure-all)。
# レンダラは exec で常駐し、awk スクリプトも起動時に一度組み立てたきり回り続ける
# ため、sidebar-render.sh を編集して chezmoi apply / source-file しても既存
# ウィンドウは古いコードのまま残る (ensure-all は既にサイドバーがあれば何もしない)。
# 結果としてウィンドウごとに描画が食い違うので、そのリセット用。
# @sidebar_enabled=0 のときは ensure_all が早期 return するため、消したままになる。
restart() {
  kill_all
  ensure_all
}

# 幅を規定値に戻す (layout-changed で崩れた分をピン留め)。冪等化してループを防ぐ
pin() {
  p=$(sb_pane_in "$1")
  [ -z "$p" ] && return 0
  w=$(width)
  cur=$(tmux display -p -t "$p" '#{pane_width}' 2>/dev/null)
  [ "$cur" != "$w" ] && tmux resize-pane -x "$w" -t "$p" 2>/dev/null
  return 0
}

pin_all() {
  tmux list-windows -a -F '#{window_id}' 2>/dev/null |
    while IFS= read -r w; do pin "$w"; done
}

# 作業ペイン (サイドバー以外) を 1 軸方向に等分に均す共通処理。
#   dir=h → 幅を等分 (左右に並んだペイン) / dir=v → 高さを等分 (上下に積んだペイン)
# select-layout even-* はサイドバーも巻き込むため使わず、作業ペインだけを目標
# サイズに設定する。各ペインの現在サイズ合計 (境界線を含まない) を K 等分し、
# 位置の先頭から K-1 個を目標値に、末尾 1 個が端数を吸収する。サイドバーは
# 対象外なので触れず、幅は pin フックが @sidebar_width に保つ。
rebalance_axis() {
  dir="$1"; win="$2"
  case "$dir" in
    v) posf='pane_top';  szf='pane_height'; flag='-y' ;;
    *) posf='pane_left'; szf='pane_width';  flag='-x' ;;
  esac
  # 「位置 サイズ ペインID」を非サイドバーだけ集め、位置の昇順に
  data=$(tmux list-panes -t "$win" -F "#{${posf}} #{${szf}} #{pane_id} #{@sidebar}" 2>/dev/null |
    awk '$4!="1"{print $1" "$2" "$3}' | sort -n)
  K=$(printf '%s\n' "$data" | grep -c .)
  [ "$K" -le 1 ] && return 0
  sum=$(printf '%s\n' "$data" | awk '{s+=$2} END{print s}')
  each=$((sum / K))
  [ "$each" -lt 1 ] && return 0
  i=1
  printf '%s\n' "$data" | while IFS=' ' read -r pos sz pid; do
    [ -z "$pid" ] && continue
    [ "$i" -ge "$K" ] && break     # 末尾は端数吸収のため触らない
    tmux resize-pane -t "$pid" "$flag" "$each" 2>/dev/null
    i=$((i + 1))
  done
}

# 作業ペインを縦横とも等分に均す。横並びだけなら幅が、縦積みだけなら高さが
# 効き、他方の軸は現状維持 (no-op) になる。
rebalance() {
  win="$1"
  [ -z "$win" ] && win=$(tmux display -p '#{window_id}' 2>/dev/null)
  [ -z "$win" ] && return 0
  rebalance_axis h "$win"
  rebalance_axis v "$win"
  pin "$win"     # サイドバー幅を @sidebar_width に戻す
}

# 端末幅に応じた自動退避 (client-resized から)。閾値をまたいだときだけ動く
reflow() {
  enabled || return 0
  cw=$(tmux display -p '#{client_width}' 2>/dev/null)
  shown=$(opt @sidebar_shown 0)
  if [ -n "$cw" ] && [ "$cw" -lt "$(min_cols)" ]; then
    [ "$shown" = "1" ] && { kill_all; tmux set -g @sidebar_shown 0; }
  else
    if [ "$shown" != "1" ]; then ensure_all; else pin_all; fi
  fi
}

case "$1" in
  ensure-window) ensure_win "$2" ;;
  ensure-all)    ensure_all ;;
  create)        create "$2" ;;
  kill-window)   kill_win "$2" ;;
  kill-all)      kill_all ;;
  prune)         prune "$2" ;;
  prune-all)     prune_all ;;
  restart)       restart ;;
  pin)           pin "$2" ;;
  pin-all)       pin_all ;;
  rebalance)     rebalance "$2" ;;
  reflow)        reflow ;;
  toggle)
    if enabled; then
      tmux set -g @sidebar_enabled 0; kill_all; tmux set -g @sidebar_shown 0
    else
      tmux set -g @sidebar_enabled 1; ensure_all
    fi
    tmux refresh-client -S 2>/dev/null
    ;;
  expand-toggle)
    if [ "$(opt @sidebar_expand 0)" = "1" ]; then tmux set -g @sidebar_expand 0
    else tmux set -g @sidebar_expand 1; fi
    ;;
  *) echo "usage: sidebar.sh {ensure-window|ensure-all|create|kill-window|kill-all|prune|prune-all|restart|pin|pin-all|rebalance|reflow|toggle|expand-toggle} [target]" >&2; exit 2 ;;
esac
