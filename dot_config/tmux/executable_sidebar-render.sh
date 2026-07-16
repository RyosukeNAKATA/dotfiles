#!/bin/sh
# 左サイドバーペインの中で回り続ける描画本体。
# セッション→ウィンドウ→ペインのツリーと、各ペインの claude / copilot 状態を
# herdr 風 (working / blocked / idle / active) に描く。
#
# 設計上の要点:
#   - 0.5 秒ループで再描画するが、「自分のウィンドウが実際に表示されているとき
#     だけ」フル描画する (非表示ウィンドウのサイドバーは軽く sleep するだけ)。
#     これでウィンドウ数に関係なくフル描画は実質 1 つに抑えられる。
#   - claude 状態は各ペインの @claude_state (フックが設定) を読むだけなので安価。
#     copilot は単一実行バイナリなので #{pane_current_command} == "copilot" で判定。
#   - ツリーの組み立て・色付け・幅クリップ・縦溢れ圧縮はすべて awk 1 プロセスで
#     行う (1 フレームあたり tmux + awk の数フォークのみ)。
#   - 現在セッションは全展開、他セッションは折りたたみ (@sidebar_expand=1 で全展開)。
#   - 縦が溢れたら現在セッションを最優先で残し、他セッションを下から圧縮する。

SELF="$TMUX_PANE"
US=$(printf '\037')          # フィールド区切り (Unit Separator)。名前/コマンドに現れない

# ---- 1 ペイン 1 行で全ペインを取得するためのフォーマット ----
FMT="#{session_name}${US}#{window_id}${US}#{window_index}${US}#{window_name}${US}#{pane_index}${US}#{pane_id}${US}#{pane_active}${US}#{pane_current_command}${US}#{@claude_state}${US}#{@sidebar}"

cleanup() { printf '\033[?25h\033[0m'; }   # カーソル復帰・属性リセット
trap cleanup EXIT INT TERM
printf '\033[?25l'                          # カーソル非表示

# ---- ツリー描画 awk (シングルクォート heredoc で $ の誤展開を防ぐ) ----
AWK=$(cat <<'AWK'
BEGIN {
  # iceberg 配色 (24bit)。RST で属性を都度リセットする
  GRN="\033[38;2;180;190;130m"; ORG="\033[38;2;226;164;120m"
  BLU="\033[38;2;132;160;198m"; PUR="\033[38;2;160;147;199m"
  FG ="\033[38;2;198;200;209m"; DIM="\033[38;2;107;112;137m"
  BOLD="\033[1m"; RST="\033[0m"
  CURWIN="\033[48;2;180;190;130m\033[38;2;22;24;37m\033[1m"   # 現在ウィンドウ: 緑背景
}
# 各ペインを記録。サイドバー自身 (@sidebar==1) は一覧にもロールアップにも含めない
{
  if ($10 == "1") next
  nr++
  S[nr]=$1; WI[nr]=$2; WIDX[nr]=$3; WN[nr]=$4
  PIDX[nr]=$5; PA[nr]=$7; CMD[nr]=$8
  cstate=$9; cmd=$8
  ag=""; lb=""; gl=""; co=""; sev=0
  if (cstate == "busy")        { ag="claude";  lb="working"; gl="\xe2\x97\x8f"; co=ORG; sev=2 }  # ●
  else if (cstate == "waiting"){ ag="claude";  lb="blocked"; gl="\xe2\x97\x8f"; co=BLU; sev=3 }  # ●
  else if (cmd == "claude")    { ag="claude";  lb="idle";    gl="\xe2\x97\x8b"; co=GRN; sev=1 }  # ○
  else if (cmd == "copilot")   { ag="copilot"; lb="active";  gl="\xe2\x97\x86"; co=PUR; sev=1 }  # ◆
  AG[nr]=ag; LB[nr]=lb; GL[nr]=gl; CO[nr]=co
  # セッション初出順を記録 (現在セッションは END で先頭に回す)
  if (!(S[nr] in sseen)) { sseen[S[nr]]=1; ORD[++nsess]=S[nr] }
  # ウィンドウ / セッション単位で最重要状態を集約 (blocked>working>active/idle)
  wk=S[nr] SUBSEP WI[nr]
  if (sev > WSEV[wk]) { WSEV[wk]=sev; WGL[wk]=gl; WCO[wk]=co; WLB[wk]=lb }
  if (sev > SSEV[S[nr]]) { SSEV[S[nr]]=sev; SGL[S[nr]]=gl; SCO[S[nr]]=co; SLB[S[nr]]=lb }
}
# ---- 1 行組み立て: put で色付き断片を足し、W を超えたらクリップ ----
function reset() { pl=""; cl="" }
function put(t,c,   rem,tt) {
  rem = W - length(pl); if (rem <= 0) return
  tt = t; if (length(tt) > rem) tt = substr(tt, 1, rem)
  pl = pl tt; cl = cl c tt RST
}
function flush() { OUT[++n] = "\033[K" cl }        # 行頭で行末までクリアしてから描く
END {
  # セッション表示順: 現在セッション (CS) を先頭、残りは初出順
  no=0
  if (CS != "" && (CS in sseen)) order[++no]=CS
  for (i=1;i<=nsess;i++) if (ORD[i]!=CS) order[++no]=ORD[i]

  for (oi=1; oi<=no; oi++) {
    s = order[oi]
    expanded = (s==CS || EXPAND=="1")
    # セッション見出し
    reset()
    if (expanded) {
      if (s==CS) { put("\xe2\x96\xbe ", GRN); put(s, GRN BOLD) }   # ▾ 現在=緑太字
      else       { put("\xe2\x96\xbe ", DIM); put(s, FG) }
    } else {
      put("\xe2\x96\xb8 ", DIM); put(s, FG)                        # ▸ 折りたたみ
      if (SSEV[s] > 0) { put(" ", FG); put(SGL[s], SCO[s]); put(" ", FG); put(SLB[s], SCO[s]) }
    }
    flush()
    if (s==CS) cur_end = n                                        # 現在セッション末尾 (溢れ保護用)
    if (!expanded) continue

    # 展開: ウィンドウ→ペイン (list-panes -a の並び順をそのまま使う)
    lastwin=""
    for (r=1; r<=nr; r++) {
      if (S[r]!=s) continue
      if (WI[r]!=lastwin) {                                        # ウィンドウ見出し
        lastwin=WI[r]
        reset()
        curwin = (s==CS && WI[r]==CW)
        if (curwin) { put("  ", FG); put(WIDX[r] " " WN[r], CURWIN) }
        else        { put("  ", FG); put(WIDX[r], DIM); put(" ", FG); put(WN[r], FG) }
        wk=s SUBSEP WI[r]
        if (WSEV[wk] > 0) { put(" ", FG); put(WGL[wk], WCO[wk]) }
        flush(); if (s==CS) cur_end=n
      }
      # ペイン行
      reset()
      curpane = (PA[r]=="1" && s==CS && WI[r]==CW)
      put("   ", FG); put(curpane ? "\xe2\x96\xb6" : " ", GRN)     # ▶ 現在ペイン
      if (AG[r] != "") { put(" ", FG); put(AG[r], FG); put(" \xc2\xb7 ", DIM); put(LB[r], CO[r]) }  # ·
      else             { put(" ", FG); put(PIDX[r], DIM); put(" ", FG); put(CMD[r], DIM) }
      flush(); if (s==CS) cur_end=n
    }
  }

  # ---- 縦溢れ処理: 現在セッションブロックを最優先で残す ----
  FR=""
  if (n <= H) {
    for (i=1;i<=n;i++) FR=FR OUT[i] "\n"
  } else {
    top = (cur_end < H ? cur_end : H)
    for (i=1;i<=top;i++) FR=FR OUT[i] "\n"
    rem = H - top
    if (rem > 0) {
      avail = rem - 1; if (avail < 0) avail = 0
      p=0
      for (i=cur_end+1; i<=n && p<avail; i++) { FR=FR OUT[i] "\n"; p++ }
      hid = n - (cur_end + p)
      if (hid > 0) FR = FR "\033[K" DIM "  +" hid " more" RST "\n"
    }
  }
  printf "\033[H%s\033[J", FR
}
AWK
)

while :; do
  # 自分のコンテキストを 1 回で取得 (window_active / session_attached / 名前 / 幅高)
  set -f; IFS="$US"
  # shellcheck disable=SC2046
  set -- $(tmux display -p -t "$SELF" -F "#{window_active}${US}#{session_attached}${US}#{session_name}${US}#{window_id}${US}#{pane_width}${US}#{pane_height}" 2>/dev/null)
  IFS=' '; set +f
  wactive="$1"; sattached="$2"; csess="$3"; cwin="$4"; W="$5"; Hgt="$6"

  # 表示中 (このウィンドウがアクティブ かつ セッションがアタッチ済み) のときだけ描く
  if [ "$wactive" = "1" ] && [ -n "$sattached" ] && [ "$sattached" != "0" ] && [ -n "$W" ]; then
    expand=$(tmux show -gqv @sidebar_expand 2>/dev/null)
    tmux list-panes -a -F "$FMT" 2>/dev/null |
      awk -F "$US" -v W="$W" -v H="$Hgt" -v CS="$csess" -v CW="$cwin" -v EXPAND="$expand" "$AWK"
  fi
  sleep 0.5
done
