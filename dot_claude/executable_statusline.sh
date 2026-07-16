#!/usr/bin/env bash
# Claude Code status line — 3-line graphical dashboard.
#
# Layout (emoji icons, ANSI colors, 1/8-cell progress bars):
#   L1 [place]    📁 owner/name › subpath      🔀 PR#N (state-colored)
#   L2 [session]  🌿 branch ✗ +staged ~mod  +add/-del  🤖 model  ⚡effort 🧠 🎨 style
#   L3 [meters]   ctx <bar10> N%   ⏳5h <bar6> N%  7d <bar6> N%   💰 $X.XX  ⏱ Mm Ss
#
# Reads the status line JSON payload on stdin. See:
#   https://code.claude.com/docs/en/statusline
# Absent/null fields (rate_limits outside Pro/Max, pr, effort, thinking, repo …)
# are hidden gracefully. Git state is cached per session_id for 3s.
set -u

input=$(cat)

# ---- JSON extraction -------------------------------------------------------
have_jq=0
if command -v jq >/dev/null 2>&1 && printf '%s' "$input" | jq -e . >/dev/null 2>&1; then
  have_jq=1
fi
j() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

if [ "$have_jq" = 1 ]; then
  cwd=$(j '.workspace.current_dir // .cwd // empty')
  session_id=$(j '.session_id // empty')
  repo_owner=$(j '.workspace.repo.owner // empty')
  repo_name=$(j '.workspace.repo.name // empty')
  model=$(j '.model.display_name // empty')
  style=$(j '.output_style.name // empty')
  effort=$(j '.effort.level // empty')
  thinking=$(j '.thinking.enabled // empty')
  ctx_used=$(j '.context_window.used_percentage // empty')
  five=$(j '.rate_limits.five_hour.used_percentage // empty')
  seven=$(j '.rate_limits.seven_day.used_percentage // empty')
  cost=$(j '.cost.total_cost_usd // empty')
  dur=$(j '.cost.total_duration_ms // empty')
  added=$(j '.cost.total_lines_added // empty')
  removed=$(j '.cost.total_lines_removed // empty')
  pr_num=$(j '.pr.number // empty')
  pr_state=$(j '.pr.review_state // empty')
else
  cwd=""; session_id=""; repo_owner=""; repo_name=""; model=""; style=""
  effort=""; thinking=""; ctx_used=""; five=""; seven=""; cost=""; dur=""
  added=""; removed=""; pr_num=""; pr_state=""
fi
[ -z "$cwd" ] && cwd="$PWD"

# ---- colors: Iceberg (dark) palette, 24-bit truecolor ----------------------
# All hues are from the Iceberg colorscheme (cocopon/iceberg.vim).
R=$'\033[0m'; B=$'\033[1m'
C_BLUE=$'\033[38;2;132;160;198m'   # #84a0c6 blue    — place / repo
C_MAG=$'\033[38;2;160;147;199m'    # #a093c7 purple  — model
C_CYAN=$'\033[38;2;137;184;194m'   # #89b8c2 cyan    — effort
C_GRAY=$'\033[38;2;107;112;137m'   # #6b7089 comment — subpath / style / % / duration
C_YEL=$'\033[38;2;226;164;120m'    # #e2a478 yellow  — dirty / modified / cost
C_GRN=$'\033[38;2;180;190;130m'    # #b4be82 green   — branch / staged / bar (low)
C_RED=$'\033[38;2;226;120;120m'    # #e27878 red     — deleted / bar (high)
C_DIM=$'\033[38;2;68;75;113m'      # #444b71 linenr  — empty bar track

round() { awk -v x="$1" 'BEGIN{ if (x=="" || x=="null") exit 1; printf "%.0f", x }' 2>/dev/null; }

bar_color() { # $1 pct(int) -> green<70 / yellow70-89 / red90+
  if   [ "$1" -ge 90 ]; then printf '%s' "$C_RED"
  elif [ "$1" -ge 70 ]; then printf '%s' "$C_YEL"
  else printf '%s' "$C_GRN"; fi
}

draw_bar() { # $1 pct(int) $2 width(cells) -> colored 1/8-resolution bar
  local pct=$1 width=$2
  [ "$pct" -lt 0 ] && pct=0
  [ "$pct" -gt 100 ] && pct=100
  local eighths=$(( pct * width * 8 / 100 ))
  local full=$(( eighths / 8 )) rem=$(( eighths % 8 ))
  local parts=(" " "▏" "▎" "▍" "▌" "▋" "▊" "▉")
  local bar="" i cells=$full
  for ((i=0; i<full; i++)); do bar+="█"; done
  if [ "$rem" -gt 0 ] && [ "$full" -lt "$width" ]; then
    bar+="${parts[$rem]}"; cells=$((cells+1))
  fi
  local empty=""
  for ((i=cells; i<width; i++)); do empty+="░"; done
  printf '%s%s%s%s%s' "$(bar_color "$pct")" "$bar" "$C_DIM" "$empty" "$R"
}

# ---- git state (cached per session for 3s) ---------------------------------
cache_file=""
[ -n "$session_id" ] && cache_file="${TMPDIR:-/tmp}/cc-sl-git-${session_id}"
cache_ok=0
if [ -n "$cache_file" ] && [ -f "$cache_file" ]; then
  now=$(date +%s)
  mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null || echo 0)
  [ $(( now - mtime )) -le 3 ] && cache_ok=1
fi

if [ "$cache_ok" = 1 ]; then
  git_data=$(cat "$cache_file")
else
  branch=""; dirty=0; staged=0; modified=0; subpath=""
  if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ] && dirty=1
    staged=$(git -C "$cwd" --no-optional-locks diff --cached --numstat 2>/dev/null | awk 'END{print NR}')
    modified=$(git -C "$cwd" --no-optional-locks diff --numstat 2>/dev/null | awk 'END{print NR}')
    top=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
    [ -n "$top" ] && [ "$cwd" != "$top" ] && subpath="${cwd#"$top"/}"
  fi
  # Field-separate with US (0x1f, non-whitespace) so an empty leading field
  # (e.g. branch="" outside a repo) is not collapsed by read's IFS handling.
  git_data="${branch}"$'\x1f'"${dirty}"$'\x1f'"${staged}"$'\x1f'"${modified}"$'\x1f'"${subpath}"
  [ -n "$cache_file" ] && printf '%s' "$git_data" > "$cache_file" 2>/dev/null
fi
IFS=$'\x1f' read -r branch dirty staged modified subpath <<< "$git_data"
: "${branch:=}" "${dirty:=0}" "${staged:=0}" "${modified:=0}" "${subpath:=}"

# ---- line 1: place ---------------------------------------------------------
if [ -n "$repo_owner" ] && [ -n "$repo_name" ]; then
  place="${B}${C_BLUE}${repo_owner}/${repo_name}${R}"
else
  place="${B}${C_BLUE}$(basename "$cwd")${R}"
fi
sub=""
[ -n "$subpath" ] && sub=" ${C_GRAY}› ${subpath}${R}"
pr=""
if [ -n "$pr_num" ]; then
  case "$pr_state" in
    approved)          pc="$C_GRN";;
    changes_requested) pc="$C_RED";;
    pending)           pc="$C_YEL";;
    *)                 pc="$C_GRAY";;
  esac
  pr="   🔀 ${pc}PR#${pr_num}${R}"
fi
line1="📁 ${place}${sub}${pr}"

# Degrade line 1 if it overflows the terminal width (drop subpath, then PR).
strip() { printf '%s' "$1" | sed $'s/\033\\[[0-9;]*m//g'; }
cols="${COLUMNS:-0}"
if [ "$cols" -gt 0 ]; then
  plain=$(strip "$line1")
  if [ "${#plain}" -gt "$cols" ]; then line1="📁 ${place}${pr}"; fi
  plain=$(strip "$line1")
  if [ "${#plain}" -gt "$cols" ]; then line1="📁 ${place}"; fi
fi

# ---- line 2: session -------------------------------------------------------
line2=""
if [ -n "$branch" ]; then
  seg="🌿 ${B}${C_GRN}${branch}${R}"
  [ "$dirty" = 1 ] && seg="${seg} ${C_YEL}✗${R}"
  [ "$staged" -gt 0 ] 2>/dev/null && seg="${seg} ${C_GRN}+${staged}${R}"
  [ "$modified" -gt 0 ] 2>/dev/null && seg="${seg} ${C_YEL}~${modified}${R}"
  line2="$seg"
fi
lc=""
[ -n "$added" ] && [ "$added" != 0 ] && lc="${C_GRN}+${added}${R}"
[ -n "$removed" ] && [ "$removed" != 0 ] && lc="${lc:+$lc }${C_RED}-${removed}${R}"
[ -n "$lc" ] && line2="${line2:+$line2  }${lc}"
[ -n "$model" ] && line2="${line2:+$line2   }🤖 ${C_MAG}${model}${R}"
[ -n "$effort" ] && line2="${line2:+$line2  }⚡${C_CYAN}${effort}${R}"
[ "$thinking" = true ] && line2="${line2:+$line2  }🧠"
[ -n "$style" ] && line2="${line2:+$line2  }🎨 ${C_GRAY}${style}${R}"

# ---- line 3: meters --------------------------------------------------------
cu=$(round "$ctx_used"); [ -z "$cu" ] && cu=0
line3="ctx $(draw_bar "$cu" 10) ${C_GRAY}${cu}%${R}"
f=$(round "$five")
[ -n "$f" ] && line3="${line3}   ⏳5h $(draw_bar "$f" 6) ${C_GRAY}${f}%${R}"
s=$(round "$seven")
[ -n "$s" ] && line3="${line3}   7d $(draw_bar "$s" 6) ${C_GRAY}${s}%${R}"
if [ -n "$cost" ]; then
  cf=$(awk -v c="$cost" 'BEGIN{printf "%.2f", c}' 2>/dev/null)
  [ -n "$cf" ] && line3="${line3}   💰 ${C_YEL}\$${cf}${R}"
fi
if [ -n "$dur" ]; then
  ds=$(( ${dur%.*} / 1000 )); mm=$(( ds / 60 )); ss=$(( ds % 60 ))
  line3="${line3}  ⏱ ${C_GRAY}${mm}m ${ss}s${R}"
fi

printf '%s\n%s\n%s' "$line1" "$line2" "$line3"
