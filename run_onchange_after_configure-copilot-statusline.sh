#!/usr/bin/env bash
set -euo pipefail

settings_dir="$HOME/.copilot"
settings_file="$settings_dir/settings.json"
mkdir -p "$settings_dir"

umask 077
tmp=$(mktemp "${TMPDIR:-/tmp}/copilot-settings.XXXXXX")
trap 'rm -f "$tmp"' EXIT

if [ -f "$settings_file" ]; then
  cat "$settings_file"
else
  printf '{}\n'
fi |
  jq '
    .statusLine = {
      type: "command",
      command: "bash \"$HOME/.copilot/statusline.sh\"",
      padding: 0,
      refreshInterval: 1
    }
    | .footer = ((.footer // {}) + {
        showModelEffort: false,
        showDirectory: false,
        showBranch: false,
        showContextWindow: false,
        showQuota: true,
        showAiUsed: false,
        showCodeChanges: false,
        showYolo: false,
        showCustom: true
      })
  ' > "$tmp"

if [ -f "$settings_file" ] && cmp -s "$tmp" "$settings_file"; then
  exit 0
fi

if [ -L "$settings_file" ]; then
  cat "$tmp" > "$settings_file"
else
  mv "$tmp" "$settings_file"
fi
