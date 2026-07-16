#!/bin/sh
# prefix+Tab のポップアップ・チューザ (方式 B)。
# 全セッション→ウィンドウ→ペインを状態付きで fzf に流し、選んだペインへ飛ぶ。
# サイドバーが OFF/自動退避中でもこれ単独で切り替えに使える。

US=$(printf '\037')
FMT="#{session_name}${US}#{window_index}${US}#{window_name}${US}#{pane_index}${US}#{pane_id}${US}#{pane_current_command}${US}#{@claude_state}${US}#{@sidebar}"

# 各ペインを「色付き表示<TAB>pane_id」の行にする (サイドバー自身は除外)
list=$(tmux list-panes -a -F "$FMT" 2>/dev/null | awk -F "$US" '
BEGIN {
  GRN="\033[38;2;180;190;130m"; ORG="\033[38;2;226;164;120m"
  BLU="\033[38;2;132;160;198m"; PUR="\033[38;2;160;147;199m"
  RED="\033[38;2;226;120;120m"; BOLD="\033[1m"
  FG ="\033[38;2;198;200;209m"; DIM="\033[38;2;107;112;137m"; RST="\033[0m"
}
$8 == "1" { next }                                  # サイドバーは載せない
{
  sess=$1; widx=$2; wname=$3; pidx=$4; pid=$5; cmd=$6; cst=$7
  lb=""; co=""
  if (cst=="busy")          { lb="working"; co=ORG }
  else if (cst=="attention"){ lb="blocked"; co=RED BOLD }   # 許可/選択待ちは赤＋太字で強調
  else if (cst=="waiting")  { lb="waiting"; co=BLU }        # 通常の入力待ちは元の色 (青)
  else if (cmd=="claude") { lb="claude idle"; co=GRN }
  else if (cmd=="copilot"){ lb="copilot active"; co=PUR }
  disp = DIM sess RST "  " FG widx ":" wname RST "  " DIM pidx RST " "
  disp = disp (lb!="" ? co lb RST : DIM cmd RST)
  printf "%s\t%s\n", disp, pid
}')

[ -z "$list" ] && exit 0

sel=$(printf '%s\n' "$list" | fzf --ansi --delimiter='\t' --with-nth=1 \
  --no-multi --reverse --border --prompt='go > ' \
  --preview='tmux capture-pane -ep -t {2}' --preview-window='right,60%,border-left')
[ -z "$sel" ] && exit 0

pid=$(printf '%s' "$sel" | awk -F '\t' '{print $2}')
[ -z "$pid" ] && exit 0

sess=$(tmux display -p -t "$pid" '#{session_name}')
win=$(tmux display -p -t "$pid" '#{window_id}')
tmux switch-client -t "$sess" 2>/dev/null
tmux select-window -t "$win" 2>/dev/null
tmux select-pane -t "$pid" 2>/dev/null
