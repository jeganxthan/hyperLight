#!/usr/bin/env bash
set -euo pipefail

sleep_after_lock_s="${1:-}"

if pgrep -x hyprlock >/dev/null 2>&1; then
  exit 0
fi

sleep_timer_pid=""
if [[ "$sleep_after_lock_s" =~ ^[0-9]+$ ]] && [ "$sleep_after_lock_s" -gt 0 ]; then
  (
    sleep "$sleep_after_lock_s"
    if pgrep -x hyprlock >/dev/null 2>&1; then
      systemctl suspend >/dev/null 2>&1 || loginctl suspend >/dev/null 2>&1 || true
    fi
  ) &
  sleep_timer_pid=$!
fi

if command -v hyprlock >/dev/null 2>&1; then
  if hyprlock -c /home/jegan/.config/hypr/hyprlock.conf; then
    [ -n "$sleep_timer_pid" ] && kill "$sleep_timer_pid" >/dev/null 2>&1 || true
    exit 0
  fi
fi

[ -n "$sleep_timer_pid" ] && kill "$sleep_timer_pid" >/dev/null 2>&1 || true

if command -v loginctl >/dev/null 2>&1; then
  loginctl lock-session
  exit 0
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Lock failed" "hyprlock and loginctl lock-session failed"
fi
