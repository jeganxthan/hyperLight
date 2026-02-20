#!/usr/bin/env bash
set -euo pipefail

if pgrep -x hyprlock >/dev/null 2>&1; then
  exit 0
fi

dpms_timer_pid=""
if command -v hyprctl >/dev/null 2>&1; then
  # If lock screen is still active after 40s, turn displays off.
  (
    sleep 40
    if pgrep -x hyprlock >/dev/null 2>&1; then
      hyprctl dispatch dpms off >/dev/null 2>&1 || true
    fi
  ) &
  dpms_timer_pid=$!
fi

if command -v hyprlock >/dev/null 2>&1; then
  if hyprlock -c /home/jegan/.config/hypr/hyprlock.conf; then
    [ -n "$dpms_timer_pid" ] && kill "$dpms_timer_pid" >/dev/null 2>&1 || true
    command -v hyprctl >/dev/null 2>&1 && hyprctl dispatch dpms on >/dev/null 2>&1 || true
    exit 0
  fi
fi

[ -n "$dpms_timer_pid" ] && kill "$dpms_timer_pid" >/dev/null 2>&1 || true
command -v hyprctl >/dev/null 2>&1 && hyprctl dispatch dpms on >/dev/null 2>&1 || true

if command -v loginctl >/dev/null 2>&1; then
  loginctl lock-session
  exit 0
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Lock failed" "hyprlock and loginctl lock-session failed"
fi
