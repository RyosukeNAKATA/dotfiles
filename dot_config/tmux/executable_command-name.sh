#!/bin/sh
# tty のフォアグラウンドプロセスから CLI ツール名を解決する
#   $1: ペインの tty (#{pane_tty})
#   $2: コマンド名のフォールバック値 (#{pane_current_command})
#
# tmux の #{pane_current_command} はカーネル上の実行ファイル名を返すため、
# Claude Code のようにバージョン番号名のバイナリ (例: 2.1.202) で動くツールや
# node 経由で起動する CLI (copilot, opencode など) では何のコマンドか分からない。
# ここでは tty のフォアグラウンドプロセスの argv からコマンド名を求める。

tty_name="${1#/dev/}"
fallback="$2"

# フォアグラウンドプロセスグループ (stat に '+') の先頭行 = グループリーダー
args=$(ps -t "$tty_name" -o stat=,args= 2>/dev/null |
  awk '$1 ~ /^[^?]*\+/ { $1=""; sub(/^ +/, ""); print; exit }')

if [ -z "$args" ]; then
  printf '%s' "$fallback"
  exit 0
fi

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

printf '%s' "$name"
