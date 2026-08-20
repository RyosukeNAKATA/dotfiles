#!/bin/sh
# 左サイドバーペインの中で回り続ける描画本体。
# 上部に「現在ペインの git コンテキスト (プロジェクト / worktree / ブランチ / 変更数)」を、
# その下にセッション→ウィンドウ→ペインのツリーを描く。各ペインの claude / copilot 状態は
# herdr 風 (working / blocked / idle / active) に色分けする。
#
# 設計上の要点:
#   - 0.5 秒ループで再描画するが、「自分のウィンドウが実際に表示されているとき
#     だけ」フル描画する (非表示ウィンドウのサイドバーは軽く sleep するだけ)。
#     これでウィンドウ数に関係なくフル描画は実質 1 つに抑えられる。
#   - claude 状態は各ペインの @claude_state (フックが設定) を読むだけなので安価。
#     copilot は単一実行バイナリなので #{pane_current_command} == "copilot" で判定。
#   - git 情報は直接叩かない。大きなリポジトリの git status は 200ms 超かかり 0.5 秒
#     ループが破綻するため、数秒おきに sidebar-git.sh をバックグラウンドへ投げ、
#     描画側はそれが書いたキャッシュファイルを awk の入力ファイルとして読むだけにする。
#   - ツリーの組み立て・色付け・幅クリップ・折り返し・縦溢れ圧縮はすべて awk 1 プロセスで
#     行う (1 フレームあたり tmux 2 + awk 1 フォークのみ)。
#   - 現在セッションは全展開、他セッションは折りたたみ (@sidebar_expand=1 で全展開)。
#   - 縦が溢れたら現在セッションを最優先で残し、他セッションを下から圧縮する。

# tmux が新規ペインに与えるデフォルトの $PATH には Homebrew / nix の bin が
# 含まれず、ここで呼ぶ tmux 自体が "command not found" になり得るため補強する
# (sidebar.sh 側の export と同じ内容。あちらは sidebar.sh 自身のプロセス内でしか
# 効かず、split-window/respawn-pane で新しく起動されるこのプロセスには伝わらない)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/run/current-system/sw/bin:$PATH"

# 自分のペイン ID: sidebar.sh が respawn-pane 時に第1引数として明示的に渡す。
# 引数が無い手動実行時のみ $TMUX_PANE にフォールバックする
SELF="${1:-$TMUX_PANE}"
US=$(printf '\037')          # フィールド区切り (Unit Separator)。名前/コマンドに現れない

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
GITSH="$DIR/sidebar-git.sh"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-sidebar"
GIT_CACHE="$CACHE_DIR/git.tsv"
GIT_EVERY=8                  # 0.5 秒 × 8 = 約 4 秒ごとに git 情報を更新
# ペイン一覧の受け渡し用 (awk の第 2 入力ファイル)。共有の /tmp ではなく自分だけの
# キャッシュディレクトリに置く (他ユーザが同名を先回りして作れる場所を避ける)
PANES="$CACHE_DIR/panes.$$"
mkdir -p "$CACHE_DIR" 2>/dev/null

# ---- 1 ペイン 1 行で全ペインを取得するためのフォーマット ----
# 先頭の P はレコード種別 (git キャッシュ側は G)。awk へ 2 種類のレコードを混ぜて渡す
# 末尾の #{pane_tty} はコマンド名解決 (command-name.sh)専用で、awk 側では読まない
FMT="P${US}#{session_name}${US}#{window_id}${US}#{window_index}${US}#{window_name}${US}#{pane_index}${US}#{pane_id}${US}#{pane_active}${US}#{pane_current_command}${US}#{@claude_state}${US}#{@sidebar}${US}#{pane_current_path}${US}#{@agy_state}${US}#{pane_tty}"
PANES_RAW="$CACHE_DIR/panes-raw.$$"

cleanup() { printf '\033[?25h\033[0m'; rm -f "$PANES" "$PANES_RAW"; }   # カーソル復帰・属性リセット
trap cleanup EXIT INT TERM
printf '\033[?25l'                          # カーソル非表示

# ---- 描画 awk (シングルクォート heredoc で $ の誤展開を防ぐ) ----
AWK=$(cat <<'AWK'
BEGIN {
  # iceberg 配色 (24bit)。RST で属性を都度リセットする
  GRN="\033[38;2;180;190;130m"; ORG="\033[38;2;226;164;120m"
  BLU="\033[38;2;132;160;198m"; PUR="\033[38;2;160;147;199m"
  RED="\033[38;2;226;120;120m"   # 入力待ち(blocked)を目立たせる赤 (iceberg red)
  CYN="\033[38;2;137;184;194m"   # worktree 名 (アクティブ枠と同じ iceberg cyan)
  FG ="\033[38;2;198;200;209m"; DIM="\033[38;2;107;112;137m"
  BOLD="\033[1m"; RST="\033[0m"
  CURWIN="\033[48;2;180;190;130m\033[38;2;22;24;37m\033[1m"   # 現在ウィンドウ: 緑背景

  # 表示幅 1 セルのグリフ。awk は文字列をバイト単位で数えるため、幅は putg の
  # 第 3 引数で明示して桁計算とズレないようにする
  G_BAR ="\xe2\x96\x8c"   # ▌ プロジェクト見出しのアクセントバー
  G_WT  ="\xe2\x91\x82"   # ⑂ worktree
  G_BR  ="\xee\x82\xa0"   #  ブランチ (Nerd Font / powerline)
  G_UP  ="\xe2\x86\x91"   # ↑ ahead
  G_DN  ="\xe2\x86\x93"   # ↓ behind
  G_OK  ="\xe2\x9c\x93"   # ✓ 変更なし
  G_RULE="\xe2\x94\x80"   # ─ 区切り線
  SP="                                                                                "
  RULES=""
  for (i = 0; i < W; i++) RULES = RULES G_RULE   # 区切り線 1 本ぶんのグリフ列
}

# ---- git 情報キャッシュ (sidebar-git.sh が書く。awk の第 1 入力ファイル) ----
# G <path> <project> <worktree> <branch> <modified> <staged> <untracked> <ahead> <behind>
$1 == "G" {
  gp = $2
  PRJ[gp] = $3; WT[gp] = $4; BRN[gp] = $5
  # 数値は git status を撮ったパスだけ入る (未計測は "-")
  if ($6 != "-" && $6 != "") {
    MOD[gp] = $6 + 0; STG[gp] = $7 + 0; UNT[gp] = $8 + 0; AHD[gp] = $9 + 0; BHD[gp] = $10 + 0
  }
  next
}

# ---- ペイン一覧。サイドバー自身 ($11==1) は一覧にもロールアップにも含めない ----
$1 == "P" {
  if ($11 == "1") next
  nr++
  S[nr]=$2; WI[nr]=$3; WIDX[nr]=$4; WN[nr]=$5
  PIDX[nr]=$6; PA[nr]=$8; CMD[nr]=$9; PP[nr]=$12
  cstate=($10!=""?$10:$13); cmd=$9
  agent_name = (cmd=="agy"||cmd=="antigravity") ? "agy" : (cmd=="claude" ? "claude" : (cmd!=""?cmd:"ai"))
  ag=""; lb=""; gl=""; co=""; sev=0
  if (cstate == "busy")          { ag=agent_name; lb="working"; gl="\xe2\x97\x8f"; co=ORG;      sev=2 }  # ●
  # attention = 許可要求 / 選択待ち (Notification フックが設定)。赤＋太字で最優先に目立たせる
  else if (cstate == "attention"){ ag=agent_name; lb="blocked"; gl="\xe2\x97\x8f"; co=RED BOLD; sev=4 }  # ●
  # waiting = 応答終了後の通常の入力待ち (Stop 由来)。元の色 (青) のまま
  else if (cstate == "waiting")  { ag=agent_name; lb="waiting"; gl="\xe2\x97\x8f"; co=BLU;      sev=3 }  # ●
  else if (cmd == "claude")      { ag="claude";  lb="idle";    gl="\xe2\x97\x8b"; co=GRN;      sev=1 }  # ○
  else if (cmd == "agy" || cmd == "antigravity") { ag="agy"; lb="idle"; gl="\xe2\x97\x8b"; co=GRN; sev=1 }  # ○
  else if (cmd == "copilot")     { ag="copilot"; lb="active";  gl="\xe2\x97\x86"; co=PUR;      sev=1 }  # ◆
  AG[nr]=ag; LB[nr]=lb; GL[nr]=gl; CO[nr]=co
  # セッション初出順を記録 (現在セッションは END で先頭に回す)
  if (!(S[nr] in sseen)) { sseen[S[nr]]=1; ORD[++nsess]=S[nr] }
  # ウィンドウ / セッション単位で最重要状態を集約 (blocked>working>active/idle)
  wk=S[nr] SUBSEP WI[nr]
  if (sev > WSEV[wk]) { WSEV[wk]=sev; WGL[wk]=gl; WCO[wk]=co; WLB[wk]=lb }
  if (sev > SSEV[S[nr]]) { SSEV[S[nr]]=sev; SGL[S[nr]]=gl; SCO[S[nr]]=co; SLB[S[nr]]=lb }
  # ウィンドウの代表パス: アクティブペインを優先、無ければ最初のペイン
  if (!(wk in WPATH) || PA[nr] == "1") WPATH[wk] = PP[nr]
  next
}

function sp(k) { return substr(SP, 1, k) }

# ---- 1 行組み立て ----
# pl は桁数を数えるための影の文字列、cl が実際に出力する色付き文字列。
# ASCII は put、非 ASCII グリフは putg (表示セル数を明示) で足す。W を超えたらクリップ
function reset() { pl=""; cl="" }
function put(t,c,   rem,tt) {
  rem = W - length(pl); if (rem <= 0) return
  tt = t; if (length(tt) > rem) tt = substr(tt, 1, rem)
  pl = pl tt; cl = cl c tt RST
}
function putg(g,c,cells,   rem) {
  rem = W - length(pl); if (rem < cells) return
  pl = pl sp(cells); cl = cl c g RST     # 桁数はプレースホルダの空白で数える
}
function flush() { OUT[++n] = "\033[K" cl }        # 行頭で行末までクリアしてから描く
function blank() { reset(); flush() }
function rule()  { reset(); putg(substr(RULES, 1, W * 3), DIM, W); flush() }

# 先頭の種別プレフィックス (feature- / fix/ など) の長さ。無ければ 0。
# 12 桁以内に '-' か '/' があり、その後ろにも文字が続くときだけ切り出す
function prefixlen(t,   i, c, L) {
  L = length(t)
  for (i = 1; i <= L && i <= 12; i++) {
    c = substr(t, i, 1)
    if (c == "-" || c == "/") return (i < L) ? i : 0
  }
  return 0
}

# '/' を '-' に寄せて小文字化。worktree 名とブランチ名の同一判定用
# (worktree ディレクトリ chai=feature-27211_x ↔ ブランチ feature/27211_x)
function norm(s,   t) { t = tolower(s); gsub("/", "-", t); return t }

# グリフ + テキストを幅 W に収まるよう折り返して出す (省略はしない)。
#   ind   行頭インデント / g,gc 先頭グリフとその色 / text,tc 本文とその色
# 種別プレフィックスは dim にして意味のある部分を目立たせる。
# 継続行は「グリフ + 空白」のぶんだけ余分に下げて本文の左端を揃える
function wrapg(ind, g, gc, text, tc,   pre, rest, first, avail, chunk, guard, cut) {
  if (text == "") return
  pre = ""; rest = text
  cut = prefixlen(text)
  if (cut > 0) { pre = substr(text, 1, cut); rest = substr(text, cut + 1) }
  first = 1
  for (guard = 0; guard < 20; guard++) {
    reset()
    put(ind, FG)
    if (first) { putg(g, gc, 1); put(" ", FG); if (pre != "") put(pre, DIM) }
    else       { put(sp(2), FG) }
    avail = W - length(pl)
    if (avail <= 0 && !first) return          # 幅が極端に狭く前進できない
    if (avail > 0 && rest != "") {
      chunk = substr(rest, 1, avail)
      put(chunk, tc)
      rest = substr(rest, length(chunk) + 1)
    }
    flush()
    first = 0
    if (rest == "") return
  }
}

function basename(p,   b) { if (p == "") return "-"; b = p; sub(".*/", "", b); return (b == "") ? "/" : b }

# 変更数と ahead/behind。git status 未計測ならこの行自体を出さない (行数を揺らさない)
function statline(p) {
  if (!(p in MOD)) return
  reset(); put("  ", FG)
  if (MOD[p] == 0 && STG[p] == 0 && UNT[p] == 0) { putg(G_OK, GRN, 1); put(" clean", DIM) }
  else {
    if (STG[p] > 0) put("+" STG[p] " ", GRN)    # ステージ済み
    if (MOD[p] > 0) put("~" MOD[p] " ", ORG)    # 未ステージの変更
    if (UNT[p] > 0) put("?" UNT[p] " ", DIM)    # 未追跡
  }
  if (AHD[p] > 0) { put(" ", FG); putg(G_UP, BLU, 1); put(AHD[p] "", BLU) }
  if (BHD[p] > 0) { put(" ", FG); putg(G_DN, RED, 1); put(BHD[p] "", RED) }
  flush()
}

# ---- ヘッダ: 自分のウィンドウのアクティブペインの git コンテキスト ----
function header(   i, p, br) {
  p = ""
  for (i = 1; i <= nr; i++) if (S[i] == CS && WI[i] == CW && PA[i] == "1") { p = PP[i]; break }
  if (p == "") for (i = 1; i <= nr; i++) if (S[i] == CS && WI[i] == CW) { p = PP[i]; break }

  blank()                                        # 上端に余白 1 行
  if (p != "" && (p in PRJ)) {
    reset(); putg(G_BAR, GRN, 1); put(" ", FG); put(PRJ[p], FG BOLD); flush()
    if (WT[p] != "") wrapg("  ", G_WT, CYN, WT[p], CYN)
    br = BRN[p]
    # worktree 名がブランチ名由来なら重複するので出さない
    if (br != "" && norm(br) != norm(WT[p])) wrapg("  ", G_BR, BLU, br, BLU)
    statline(p)
  } else {
    reset(); putg(G_BAR, DIM, 1); put(" ", FG); put(basename(p), DIM); flush()
  }
  rule(); blank()
}

END {
  header()

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
      if (s==CS) { putg("\xe2\x96\xbe", GRN, 1); put(" ", FG); put(s, GRN BOLD) }   # ▾ 現在=緑太字
      else       { putg("\xe2\x96\xbe", DIM, 1); put(" ", FG); put(s, FG) }
    } else {
      putg("\xe2\x96\xb8", DIM, 1); put(" ", FG); put(s, FG)                        # ▸ 折りたたみ
      if (SSEV[s] > 0) { put(" ", FG); putg(SGL[s], SCO[s], 1); put(" ", FG); put(SLB[s], SCO[s]) }
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
        wk=s SUBSEP WI[r]
        wp=WPATH[wk]
        # git 管理下ならプロジェクト名を見出しにする (ウィンドウ名は自動リネームで
        # コマンド名になり、ペイン行と重複するため)。管理外はウィンドウ名のまま
        lbl = (wp != "" && (wp in PRJ)) ? PRJ[wp] : WN[r]
        reset()
        curwin = (s==CS && WI[r]==CW)
        if (curwin) { put("  ", FG); put(WIDX[r] " " lbl, CURWIN) }
        else        { put("  ", FG); put(WIDX[r], DIM); put(" ", FG); put(lbl, FG) }
        if (WSEV[wk] > 0) { put(" ", FG); putg(WGL[wk], WCO[wk], 1) }
        flush()
        # linked worktree は worktree 名 (⑂ / cyan)、メイン worktree はブランチ名 ( / 薄字) を
        # 出す。グリフでどちらのチェックアウトかが一目で分かる
        if (wp != "" && (wp in PRJ)) {
          if (WT[wp] != "") wrapg("    ", G_WT, CYN, WT[wp], CYN)
          else              wrapg("    ", G_BR, DIM, BRN[wp], DIM)
        }
        if (s==CS) cur_end=n
      }
      # ペイン行
      reset()
      curpane = (PA[r]=="1" && s==CS && WI[r]==CW)
      put("   ", FG)
      if (curpane) putg("\xe2\x96\xb6", GRN, 1); else put(" ", FG)  # ▶ 現在ペイン
      if (AG[r] != "") { put(" ", FG); put(AG[r], FG); put(" ", FG); putg("\xc2\xb7", DIM, 1); put(" ", FG); put(LB[r], CO[r]) }
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

frame=0
while :; do
  # 自分のコンテキストを 1 回で取得 (window_active / session_attached / 名前 / 幅高)
  set -f; IFS="$US"
  # shellcheck disable=SC2046
  set -- $(tmux display -p -t "$SELF" -F "#{window_active}${US}#{session_attached}${US}#{session_name}${US}#{window_id}${US}#{pane_width}${US}#{pane_height}" 2>/dev/null)
  IFS=' '; set +f
  wactive="$1"; sattached="$2"; csess="$3"; cwin="$4"; W="$5"; Hgt="$6"

  # 表示中 (このウィンドウがアクティブ かつ セッションがアタッチ済み) のときだけ描く
  if [ "$wactive" = "1" ] && [ -n "$sattached" ] && [ "$sattached" != "0" ] && [ -n "$W" ]; then
    # git 情報の更新はバックグラウンドへ投げるだけ (描画をブロックしない)。
    # 表示中のサイドバーだけが投げるので、ウィンドウ数が増えても同時実行は増えない
    # (さらに sidebar-git.sh 側でロックして二重起動を抑える)
    if [ "$((frame % GIT_EVERY))" -eq 0 ]; then
      "$GITSH" refresh >/dev/null 2>&1 &
    fi
    frame=$((frame + 1))

    expand=$(tmux show -gqv @sidebar_expand 2>/dev/null)
    tmux list-panes -a -F "$FMT" >"$PANES_RAW" 2>/dev/null
    # pane_current_command はカーネル上の実行ファイル名 (claude のようにバージョン
    # 番号名のバイナリだと "2.1.237" のような表示になる) なので、pane-title.sh と
    # 同じ command-name.sh で argv から解決した名前に差し替える (末尾の pane_tty を消費)
    : >"$PANES"
    while IFS="$US" read -r rtype rs rwid rwidx rwname rpidx rpid rpact rcmd rcstate rsb rpath ragst rtty; do
      [ "$rtype" = "P" ] || continue
      name=$("$DIR/command-name.sh" "$rtty" "$rcmd")
      printf 'P%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n' \
        "$US" "$rs" "$US" "$rwid" "$US" "$rwidx" "$US" "$rwname" "$US" "$rpidx" "$US" "$rpid" \
        "$US" "$rpact" "$US" "$name" "$US" "$rcstate" "$US" "$rsb" "$US" "$rpath" "$US" "$ragst"
    done <"$PANES_RAW" >"$PANES"
    cache="$GIT_CACHE"; [ -f "$cache" ] || cache=/dev/null
    awk -F "$US" -v W="$W" -v H="$Hgt" -v CS="$csess" -v CW="$cwin" -v EXPAND="$expand" \
      "$AWK" "$cache" "$PANES"
  fi
  sleep 0.5
done
