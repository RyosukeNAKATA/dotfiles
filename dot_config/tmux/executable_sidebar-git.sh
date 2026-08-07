#!/bin/sh
# 左サイドバーが表示する git 情報 (プロジェクト名 / worktree 名 / ブランチ /
# 変更数 / ahead-behind) をキャッシュファイルへ書き出すワンショット更新スクリプト。
#
# なぜキャッシュを挟むか:
#   sidebar-render.sh は 0.5 秒ループで描画するが、git status は大きめのリポジトリだと
#   200ms 超かかる (実測: chai で 0.23s)。レンダラから直接叩くと 0.5 秒ループが破綻する
#   ため、レンダラは数秒おきにこのスクリプトをバックグラウンドへ投げるだけにし、描画側は
#   キャッシュファイルを awk の入力ファイルとして読むだけに留める (追加フォークなし)。
#
# 出力 1 行の形式 (US = \037 区切り、先頭の G はレコード種別):
#   G <path> <project> <worktree> <branch> <modified> <staged> <untracked> <ahead> <behind>
#     project  … リポジトリ名。git-common-dir の親ディレクトリ名
#                (bare リポジトリなら repo.git の repo 部分)
#     worktree … linked worktree のディレクトリ名から `<project>=` 接頭辞を除いたもの。
#                メイン worktree では空文字。
#                例: chai=feature-27211_x → feature-27211_x
#     数値5項目 … git status を撮ったパスのみ実数。未計測は `-`
#                (レンダラは変更数の行自体を出さない)
#
# 計測の粒度 (コストを抑えるための切り分け):
#   - 全ペインの cwd        … rev-parse だけ (数 ms) で project / worktree / branch を解決
#   - アクティブペインの cwd … 加えて git status で変更数と ahead/behind を撮る
#     (ウィンドウごとに 1 つなので通常 3〜6 パス。切り替えても即座に数字が出るよう
#      「今見えているウィンドウ」に絞らず全ウィンドウのアクティブペインを対象にする)
#
# usage: sidebar-git.sh refresh
#        sidebar-git.sh resolve <path> [1]   # デバッグ用に 1 パスだけ解決して表示

US=$(printf '\037')
NL='
'
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-sidebar"
CACHE="$CACHE_DIR/git.tsv"
LOCK="$CACHE_DIR/refresh.lock"

# 1 パス分のキャッシュ行を組み立てて標準出力へ。git 管理下でなければ何も出さない
#   $1: 対象パス / $2: 1 なら git status も撮る
resolve() {
  p="$1"
  want_status="$2"

  # 4 つの情報を 1 プロセスで取る。出力はオプションを並べた順 (実測で確認済み):
  #   1: worktree のトップ / 2: この worktree の gitdir / 3: 共通 gitdir / 4: ブランチ名
  # --path-format=absolute がないとメイン worktree 内では `.git` の相対パスが返る
  info=$(git -C "$p" rev-parse --path-format=absolute \
    --show-toplevel --git-dir --git-common-dir --abbrev-ref HEAD 2>/dev/null) || return 0

  top=${info%%"$NL"*}; rest=${info#*"$NL"}
  gdir=${rest%%"$NL"*}; rest=${rest#*"$NL"}
  cdir=${rest%%"$NL"*}
  branch=${rest#*"$NL"}
  [ -n "$top" ] && [ -n "$cdir" ] || return 0

  # プロジェクト名: 共通 gitdir が `<repo>/.git` なら親ディレクトリ名、
  # bare (`<repo>.git`) なら `.git` を落とした名前
  cbase=${cdir##*/}
  if [ "$cbase" = ".git" ]; then
    pdir=${cdir%/*}
    project=${pdir##*/}
  else
    project=${cbase%.git}
  fi

  # worktree 名: gitdir と共通 gitdir が違えば linked worktree。
  # `<project>=<slug>` という命名なら接頭辞を落として slug だけ見せる
  wt=""
  if [ "$gdir" != "$cdir" ]; then
    wt=${top##*/}
    case "$wt" in
    "$project="*) wt=${wt#"$project="} ;;
    esac
  fi

  # detached HEAD はブランチ名が "HEAD" になるので短縮 SHA に差し替える
  if [ "$branch" = "HEAD" ]; then
    sha=$(git -C "$p" rev-parse --short HEAD 2>/dev/null)
    [ -n "$sha" ] && branch="@$sha"
  fi

  m="-"; s="-"; u="-"; a="-"; b="-"
  if [ "$want_status" = "1" ]; then
    # --branch の 1 行目 (`## br...origin/br [ahead 2, behind 1]`) から ahead/behind を、
    # 残りの行頭 2 文字から staged / modified / untracked をまとめて数える
    counts=$(git -C "$p" status --porcelain=v1 --branch 2>/dev/null | awk '
      NR == 1 && substr($0, 1, 3) == "## " {
        if (match($0, /ahead [0-9]+/))  ah = substr($0, RSTART + 6, RLENGTH - 6)
        if (match($0, /behind [0-9]+/)) bh = substr($0, RSTART + 7, RLENGTH - 7)
        next
      }
      {
        x = substr($0, 1, 1); y = substr($0, 2, 1)
        if (x == "?") { un++; next }
        if (x != " ") st++
        if (y != " ") md++
      }
      END { printf "%d %d %d %d %d\n", md + 0, st + 0, un + 0, ah + 0, bh + 0 }')
    if [ -n "$counts" ]; then
      # shellcheck disable=SC2086
      set -- $counts
      m="$1"; s="$2"; u="$3"; a="$4"; b="$5"
    fi
  fi

  printf '%s\n' "G${US}${p}${US}${project}${US}${wt}${US}${branch}${US}${m}${US}${s}${US}${u}${US}${a}${US}${b}"
}

# 全ペインの cwd を解決してキャッシュを書き直す
refresh() {
  mkdir -p "$CACHE_DIR" 2>/dev/null || return 0

  # 二重起動の抑制。レンダラはウィンドウ/クライアントごとに走るため複数から呼ばれる。
  # 異常終了で残ったロックは 5 分経っていれば残骸として奪う
  if ! mkdir "$LOCK" 2>/dev/null; then
    [ -n "$(find "$LOCK" -maxdepth 0 -mmin +5 2>/dev/null)" ] || return 0
    rmdir "$LOCK" 2>/dev/null
    mkdir "$LOCK" 2>/dev/null || return 0
  fi
  trap 'rmdir "$LOCK" 2>/dev/null' EXIT INT TERM

  # SIGKILL などで trap が走らずに残ったレンダラの受け渡しファイル (panes.<pid>) を掃除
  find "$CACHE_DIR" -maxdepth 1 -name 'panes.*' -mtime +1 -delete 2>/dev/null

  all=$(tmux list-panes -a -F "#{@sidebar}${US}#{pane_active}${US}#{pane_current_path}" 2>/dev/null)
  [ -n "$all" ] || return 0
  # サイドバー自身 (@sidebar=1) は対象外。cwd は常にホームなので混ぜても意味がない
  paths=$(printf '%s\n' "$all" | awk -F "$US" '$1 != "1" && $3 != "" { print $3 }' | sort -u)
  active=$(printf '%s\n' "$all" | awk -F "$US" '$1 != "1" && $2 == "1" && $3 != "" { print $3 }' | sort -u)

  tmp="$CACHE.$$"
  : >"$tmp" 2>/dev/null || return 0
  printf '%s\n' "$paths" | while IFS= read -r p; do
    [ -n "$p" ] || continue
    want=0
    # active リストへの所在チェック (改行で囲んで部分一致させるので追加フォークなし)
    case "$NL$active$NL" in
    *"$NL$p$NL"*) want=1 ;;
    esac
    resolve "$p" "$want" >>"$tmp"
  done
  # 描画側が半端な内容を読まないよう rename で差し替える
  mv -f "$tmp" "$CACHE" 2>/dev/null || rm -f "$tmp"
}

case "$1" in
refresh) refresh ;;
resolve) resolve "$2" "${3:-0}" ;;
*)
  echo "usage: sidebar-git.sh {refresh|resolve <path> [1]}" >&2
  exit 2
  ;;
esac
