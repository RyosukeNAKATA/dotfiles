#!/bin/sh
# tmux のペインタイトル (スタイル指定込み) を組み立てる
#   $1: ペイン ID (#{pane_id})
#   $2: アクティブペインなら 1 (#{pane_active})
#   $3: ペイン番号 (#{pane_index})
#   $4: ペインの tty (#{pane_tty})
#   $5: コマンド名のフォールバック値 (#{pane_current_command})
#   $6: ペインのカレントディレクトリ (#{pane_current_path})
#
# 出力は「番号: コマンド名 ディレクトリ」に tmux のスタイル指定 (#[...]) を
# 付けたもの。Claude Code 実行中は ~/.claude/settings.json のフックが設定する
# ペインオプション @claude_state に応じて配色を変える:
#   busy = 応答生成中 (橙) / waiting = ユーザーの入力待ち (青)

pane_id="$1"
pane_active="$2"
pane_index="$3"
tty_name="${4#/dev/}"
fallback="$5"
cwd="$6"

# --- コマンド名の解決 ---
# tmux の #{pane_current_command} はカーネル上の実行ファイル名を返すため、
# Claude Code のようにバージョン番号名のバイナリ (例: 2.1.202) で動くツールや
# node 経由で起動する CLI では何のコマンドか分からない。
# ここでは tty のフォアグラウンドプロセスの argv からコマンド名を求める。
# フォアグラウンドプロセスグループ (stat に '+') の先頭行 = グループリーダー
args=$(ps -t "$tty_name" -o stat=,args= 2>/dev/null |
  awk '$1 ~ /^[^?]*\+/ { $1=""; sub(/^ +/, ""); print; exit }')

if [ -z "$args" ]; then
  name="$fallback"
else
  # shellcheck disable=SC2086 # argv を単語分割したいので意図的にクォートしない
  set -- $args
  # ログインシェルの argv0 は先頭に "-" が付く (-zsh) ので、
  # basename がオプションと誤認しないよう先に除去する
  arg0="${1#-}"
  name=$(basename "$arg0")

  # インタプリタ経由の起動ならスクリプト名の方を表示する
  case "$name" in
  node | bun | deno | python | python3 | ruby | perl)
    if [ -n "$2" ]; then
      name=$(basename "$2")
    fi
    ;;
  esac
fi

# --- カレントディレクトリの整形 ---
# ホームディレクトリからの相対パス (~ 表記) にする。
# ホーム配下でなければフルパスのまま扱う
dir=""
case "$cwd" in
"") ;;
"$HOME") dir="~" ;;
"$HOME"/*) dir="~${cwd#"$HOME"}" ;;
*) dir="$cwd" ;;
esac

# 3階層以上の深さなら最後の2階層だけ表示する
case "$dir" in
*/*/*)
  parent="${dir%/*}"
  dir="${parent##*/}/${dir##*/}"
  ;;
esac

# --- Claude Code の状態取得 ---
# フック (~/.claude/settings.json) がペインオプションに設定した値を読む
state=""
if [ "$name" = "claude" ]; then
  state=$(tmux show -pqv -t "$pane_id" @claude_state 2>/dev/null)
fi

# --- 配色の決定 (iceberg: 緑 #b4be82 / 橙 #e2a478 / 青 #84a0c6) ---
# アクティブペインは背景色で塗り、非アクティブは文字色だけで状態を示す
if [ "$pane_active" = "1" ]; then
  case "$state" in
  busy) style="#[fg=#161825 bg=#e2a478 bold]" ;;
  waiting) style="#[fg=#161825 bg=#84a0c6 bold]" ;;
  *) style="#[fg=#161825 bg=#b4be82 bold]" ;;
  esac
else
  case "$state" in
  busy) style="#[fg=#e2a478]" ;;
  waiting) style="#[fg=#84a0c6]" ;;
  *) style="#[fg=#6b7089]" ;;
  esac
fi

title="$pane_index: $name"
if [ -n "$dir" ]; then
  title="$title $dir"
fi

printf '%s %s #[default]' "$style" "$title"
