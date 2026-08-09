#!/usr/bin/env bash
set -euo pipefail

settings_dir="$HOME/.gemini/antigravity-cli"
settings_file="$settings_dir/settings.json"
mkdir -p "$settings_dir"

umask 077
tmp=$(mktemp "${TMPDIR:-/tmp}/antigravity-settings.XXXXXX")
trap 'rm -f "$tmp"' EXIT

if [ -f "$settings_file" ]; then
  cat "$settings_file"
else
  printf '{}\n'
fi |
  jq '
    .statusLine = {
      type: "command",
      command: "bash \"$HOME/.gemini/antigravity-cli/statusline.sh\"",
      padding: 0,
      refreshInterval: 1
    }
    | .hooks = {
        UserPromptSubmit: [
          {
            hooks: [
              {
                type: "command",
                command: "[ -z \"$TMUX_PANE\" ] || tmux set-option -p -t \"$TMUX_PANE\" @agy_state busy 2>/dev/null || true"
              }
            ]
          }
        ],
        PreToolUse: [
          {
            hooks: [
              {
                type: "command",
                command: "[ -z \"$TMUX_PANE\" ] || tmux set-option -p -t \"$TMUX_PANE\" @agy_state busy 2>/dev/null || true"
              }
            ]
          }
        ],
        Stop: [
          {
            hooks: [
              {
                type: "command",
                command: "[ -z \"$TMUX_PANE\" ] || tmux set-option -p -t \"$TMUX_PANE\" @agy_state waiting 2>/dev/null || true"
              }
            ]
          }
        ],
        Notification: [
          {
            hooks: [
              {
                type: "command",
                command: "in=$(cat); [ -z \"$TMUX_PANE\" ] && exit 0; printf '\''%s'\'' \"$in\" | grep -qi permission && s=attention || s=waiting; tmux set-option -p -t \"$TMUX_PANE\" @agy_state \"$s\" 2>/dev/null || true"
              }
            ]
          }
        ],
        SessionStart: [
          {
            hooks: [
              {
                type: "command",
                command: "[ -z \"$TMUX_PANE\" ] || tmux set-option -p -t \"$TMUX_PANE\" @agy_state waiting 2>/dev/null || true"
              }
            ]
          }
        ],
        SessionEnd: [
          {
            hooks: [
              {
                type: "command",
                command: "[ -z \"$TMUX_PANE\" ] || tmux set-option -p -t \"$TMUX_PANE\" -u @agy_state 2>/dev/null || true"
              }
            ]
          }
        ]
      }
  ' > "$tmp"

if [ -f "$settings_file" ] && cmp -s "$tmp" "$settings_file"; then
  exit 0
fi

if [ -L "$settings_file" ]; then
  cat "$tmp" > "$settings_file"
else
  mv "$tmp" "$settings_file"
fi
