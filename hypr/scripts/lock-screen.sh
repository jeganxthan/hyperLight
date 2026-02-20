#!/usr/bin/env bash
set -euo pipefail

if pgrep -x hyprlock >/dev/null 2>&1; then
  exit 0
fi

if command -v hyprlock >/dev/null 2>&1; then
  if hyprlock -c /home/jegan/.config/hypr/hyprlock.conf; then
    exit 0
  fi
fi

if command -v loginctl >/dev/null 2>&1; then
  loginctl lock-session
  exit 0
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Lock failed" "hyprlock and loginctl lock-session failed"
fi
