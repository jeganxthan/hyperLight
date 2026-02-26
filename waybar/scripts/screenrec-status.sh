#!/usr/bin/env bash
set -euo pipefail

if pgrep -x wf-recorder >/dev/null 2>&1; then
  printf '{"text":"⏺ rec","class":"recording","tooltip":"Screen recording is active\\nClick to stop"}\n'
else
  # Hidden by waybar exec-if when not recording.
  exit 1
fi
