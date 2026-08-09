#!/usr/bin/env bash
# Antigravity CLI status line — compact graphical session dashboard.
#
# Layout:
#   L1 📁 owner/repo › subpath   🌿 branch ✗ +staged ~modified
#   L2 🤖 model   in N out N cache N think N   +added/-removed
#   L3 ctx <bar> used/limit N%   ⚡ AIC N   ⏱ Hh Mm Ss
set -u

input=$(cat)

have_jq=0
if command -v jq >/dev/null 2>&1 && printf '%s' "$input" | jq -e . >/dev/null 2>&1; then
  have_jq=1
fi

j() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

if [ "$have_jq" = 1 ]; then
  cwd=$(j '.workspace.current_dir // .cwd // empty')
  session_id=$(j '.session_id // empty')
  model=$(j '.model.display_name // .model.id // empty')
  remote_connected=$(j '.remote.connected // false')
  repo_owner=$(j '.remote.repository.owner // empty')
  repo_name=$(j '.remote.repository.name // empty')
  remote_branch=$(j '.remote.repository.branch // empty')
  pr_num=$(j '.remote.pull_request_number // empty')
  ctx_used=$(j '.context_window.current_context_tokens // empty')
  ctx_limit=$(j '.context_window.displayed_context_limit // .context_window.context_window_size // empty')
  ctx_pct=$(j '.context_window.current_context_used_percentage // .context_window.used_percentage // empty')
  input_tokens=$(j '.context_window.total_input_tokens // empty')
  output_tokens=$(j '.context_window.total_output_tokens // empty')
  cache_read=$(j '.context_window.total_cache_read_tokens // 0')
  cache_write=$(j '.context_window.total_cache_write_tokens // 0')
  reasoning_tokens=$(j '.context_window.total_reasoning_tokens // empty')
  ai_used=$(j '.ai_used.formatted // empty')
  duration_ms=$(j '.cost.total_duration_ms // empty')
  added=$(j '.cost.total_lines_added // empty')
  removed=$(j '.cost.total_lines_removed // empty')
  allow_all=$(j '.allow_all_enabled // false')
else
  cwd=""
  session_id=""
  model=""
  remote_connected=false
  repo_owner=""
  repo_name=""
  remote_branch=""
  pr_num=""
  ctx_used=""
  ctx_limit=""
  ctx_pct=""
  input_tokens=""
  output_tokens=""
  cache_read=0
  cache_write=0
  reasoning_tokens=""
  ai_used=""
  duration_ms=""
  added=""
  removed=""
  allow_all=false
fi
[ -z "$cwd" ] && cwd="$PWD"

# Iceberg colors.
R=$'\033[0m'
B=$'\033[1m'
C_BLUE=$'\033[38;2;132;160;198m'
C_MAG=$'\033[38;2;160;147;199m'
C_CYAN=$'\033[38;2;137;184;194m'
C_GRAY=$'\033[38;2;107;112;137m'
C_YEL=$'\033[38;2;226;164;120m'
C_GRN=$'\033[38;2;180;190;130m'
C_RED=$'\033[38;2;226;120;120m'
C_DIM=$'\033[38;2;68;75;113m'

round() {
  awk -v x="$1" 'BEGIN {
    if (x == "" || x == "null") exit 1
    printf "%.0f", x
  }' 2>/dev/null
}

format_tokens() {
  awk -v n="$1" 'BEGIN {
    if (n == "" || n == "null") exit 1
    if (n >= 1000000) printf "%.1fM", n / 1000000
    else if (n >= 1000) printf "%.1fk", n / 1000
    else printf "%.0f", n
  }' 2>/dev/null
}

format_duration() {
  awk -v ms="$1" 'BEGIN {
    if (ms == "" || ms == "null") exit 1
    seconds = int(ms / 1000)
    hours = int(seconds / 3600)
    minutes = int((seconds % 3600) / 60)
    seconds %= 60
    if (hours > 0) printf "%dh %dm %ds", hours, minutes, seconds
    else printf "%dm %ds", minutes, seconds
  }' 2>/dev/null
}

bar_color() {
  if [ "$1" -ge 90 ]; then
    printf '%s' "$C_RED"
  elif [ "$1" -ge 70 ]; then
    printf '%s' "$C_YEL"
  else
    printf '%s' "$C_GRN"
  fi
}

draw_bar() {
  local pct=$1 width=$2
  [ "$pct" -lt 0 ] && pct=0
  [ "$pct" -gt 100 ] && pct=100

  local eighths=$((pct * width * 8 / 100))
  local full=$((eighths / 8))
  local rem=$((eighths % 8))
  local parts=(" " "▏" "▎" "▍" "▌" "▋" "▊" "▉")
  local bar="" empty="" i cells=$full

  for ((i = 0; i < full; i++)); do bar+="█"; done
  if [ "$rem" -gt 0 ] && [ "$full" -lt "$width" ]; then
    bar+="${parts[$rem]}"
    cells=$((cells + 1))
  fi
  for ((i = cells; i < width; i++)); do empty+="░"; done

  printf '%s%s%s%s%s' "$(bar_color "$pct")" "$bar" "$C_DIM" "$empty" "$R"
}

# Cache git inspection because the status command may run every second.
safe_session_id=$(printf '%s' "$session_id" | tr -cd 'A-Za-z0-9._-')
cache_file=""
[ -n "$safe_session_id" ] && cache_file="${TMPDIR:-/tmp}/agy-sl-git-${safe_session_id}"
cache_ok=0
if [ -n "$cache_file" ] && [ -f "$cache_file" ]; then
  now=$(date +%s)
  mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null || echo 0)
  [ $((now - mtime)) -le 3 ] && cache_ok=1
fi

if [ "$cache_ok" = 1 ]; then
  git_data=$(cat "$cache_file")
else
  branch=""
  dirty=0
  staged=0
  modified=0
  subpath=""
  local_owner=""
  local_name=""
  top=""

  if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ] && dirty=1
    staged=$(git -C "$cwd" --no-optional-locks diff --cached --numstat 2>/dev/null | awk 'END { print NR + 0 }')
    modified=$(git -C "$cwd" --no-optional-locks diff --numstat 2>/dev/null | awk 'END { print NR + 0 }')
    top=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
    [ -n "$top" ] && [ "$cwd" != "$top" ] && subpath="${cwd#"$top"/}"

    origin=$(git -C "$cwd" --no-optional-locks remote get-url origin 2>/dev/null)
    if [ -n "$origin" ]; then
      case "$origin" in
        *://*) slug="${origin#*://}"; slug="${slug#*/}" ;;
        *:*) slug="${origin#*:}" ;;
        *) slug="$origin" ;;
      esac
      slug="${slug%.git}"
      local_name="${slug##*/}"
      owner_path="${slug%/*}"
      local_owner="${owner_path##*/}"
    fi
  fi

  git_data="${branch}"$'\x1f'"${dirty}"$'\x1f'"${staged}"$'\x1f'"${modified}"$'\x1f'"${subpath}"$'\x1f'"${local_owner}"$'\x1f'"${local_name}"$'\x1f'"${top}"
  [ -n "$cache_file" ] && printf '%s' "$git_data" > "$cache_file" 2>/dev/null
fi

IFS=$'\x1f' read -r branch dirty staged modified subpath local_owner local_name top <<< "$git_data"
: "${branch:=}" "${dirty:=0}" "${staged:=0}" "${modified:=0}" "${subpath:=}"
: "${local_owner:=}" "${local_name:=}" "${top:=}"

if [ "$remote_connected" = true ]; then
  [ -n "$remote_branch" ] && branch="$remote_branch"
else
  [ -z "$repo_owner" ] && repo_owner="$local_owner"
  [ -z "$repo_name" ] && repo_name="$local_name"
fi

# Line 1: location and git state.
if [ -n "$repo_owner" ] && [ -n "$repo_name" ]; then
  place="${B}${C_BLUE}${repo_owner}/${repo_name}${R}"
elif [ -n "$top" ]; then
  place="${B}${C_BLUE}$(basename "$top")${R}"
else
  place="${B}${C_BLUE}$(basename "$cwd")${R}"
fi

line1="📁 ${place}"
[ -n "$subpath" ] && line1="${line1} ${C_GRAY}› ${subpath}${R}"
if [ -n "$branch" ]; then
  line1="${line1}   🌿 ${B}${C_GRN}${branch}${R}"
  [ "$dirty" = 1 ] && line1="${line1} ${C_YEL}✗${R}"
  [ "$staged" -gt 0 ] 2>/dev/null && line1="${line1} ${C_GRN}+${staged}${R}"
  [ "$modified" -gt 0 ] 2>/dev/null && line1="${line1} ${C_YEL}~${modified}${R}"
fi
[ -n "$pr_num" ] && line1="${line1}   ${C_MAG}PR#${pr_num}${R}"

# Line 2: model and cumulative token counters.
line2=""
[ -n "$model" ] && line2="🤖 ${C_MAG}${model}${R}"

token_parts=""
if [ -n "$input_tokens" ]; then
  input_display=$(format_tokens "$input_tokens")
  [ -n "$input_display" ] && token_parts="${C_BLUE}in ${input_display}${R}"
fi
if [ -n "$output_tokens" ]; then
  output_display=$(format_tokens "$output_tokens")
  [ -n "$output_display" ] && token_parts="${token_parts:+$token_parts  }${C_GRN}out ${output_display}${R}"
fi
cache_tokens=$((cache_read + cache_write))
if [ "$cache_tokens" -gt 0 ] 2>/dev/null; then
  cache_display=$(format_tokens "$cache_tokens")
  token_parts="${token_parts:+$token_parts  }${C_CYAN}cache ${cache_display}${R}"
fi
if [ -n "$reasoning_tokens" ] && [ "$reasoning_tokens" -gt 0 ] 2>/dev/null; then
  reasoning_display=$(format_tokens "$reasoning_tokens")
  token_parts="${token_parts:+$token_parts  }${C_MAG}think ${reasoning_display}${R}"
fi
[ -n "$token_parts" ] && line2="${line2:+$line2   }${token_parts}"

changes=""
[ -n "$added" ] && [ "$added" != 0 ] && changes="${C_GRN}+${added}${R}"
[ -n "$removed" ] && [ "$removed" != 0 ] && changes="${changes:+$changes }${C_RED}-${removed}${R}"
[ -n "$changes" ] && line2="${line2:+$line2   }${changes}"
[ "$allow_all" = true ] && line2="${line2:+$line2   }${B}${C_RED}YOLO${R}"

# Line 3: live context usage, AI Credits, and elapsed time.
if [ -z "$ctx_pct" ] && [ -n "$ctx_used" ] && [ -n "$ctx_limit" ]; then
  ctx_pct=$(awk -v used="$ctx_used" -v limit="$ctx_limit" 'BEGIN {
    if (limit > 0) printf "%.0f", used / limit * 100
  }')
fi
ctx_pct=$(round "${ctx_pct:-0}")
[ -z "$ctx_pct" ] && ctx_pct=0

line3="ctx $(draw_bar "$ctx_pct" 12)"
if [ -n "$ctx_used" ] && [ -n "$ctx_limit" ]; then
  ctx_used_display=$(format_tokens "$ctx_used")
  ctx_limit_display=$(format_tokens "$ctx_limit")
  line3="${line3} ${C_GRAY}${ctx_used_display}/${ctx_limit_display} ${ctx_pct}%${R}"
else
  line3="${line3} ${C_GRAY}${ctx_pct}%${R}"
fi
[ -n "$ai_used" ] && line3="${line3}   ⚡ ${C_YEL}AIC ${ai_used}${R}"
if [ -n "$duration_ms" ]; then
  duration=$(format_duration "$duration_ms")
  [ -n "$duration" ] && line3="${line3}   ⏱ ${C_GRAY}${duration}${R}"
fi

printf '%s\n%s\n%s' "$line1" "$line2" "$line3"
