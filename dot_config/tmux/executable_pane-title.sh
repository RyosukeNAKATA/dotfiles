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
pane_tty="$4"
fallback="$5"
cwd="$6"

# サイドバーペイン (sidebar.sh が @sidebar=1 を付ける) はタイトルを出さない。
# 「番号: コマンド dir」を描くと紛らわしいので空タイトルにする
if [ "$(tmux show -pqv -t "$pane_id" @sidebar 2>/dev/null)" = "1" ]; then
  exit 0
fi

# --- コマンド名の解決 ---
# バージョン番号名のバイナリや node 経由の CLI でも正しい名前になるよう、
# フォアグラウンドプロセスの argv から解決する (詳細は command-name.sh)
name=$("$(dirname "$0")/command-name.sh" "$pane_tty" "$fallback")

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
  # 状態なし = 通常のアクティブペイン。境界線 (pane-active-border-style) と
  # 揃えて iceberg の水色 (cyan) で塗り、枠全体を一様な水色にする
  *) style="#[fg=#161825 bg=#89b8c2 bold]" ;;
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

# アクティブペインは先頭に大きめの矢印マーカーを付け、一目でどのペインが
# アクティブか分かるようにする (tmux 標準の pane-border-indicators の矢印は
# グリフ 1 文字で小さいため off にし、これで代替する)
marker=""
[ "$pane_active" = "1" ] && marker="▶ "

printf '%s %s%s #[default]' "$style" "$marker" "$title"
