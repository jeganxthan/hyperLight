#!/usr/bin/env bash
set -euo pipefail

# Toggle an existing Bluetooth manager window if already running.
if pgrep -x blueman-manager >/dev/null 2>&1; then
  pkill -x blueman-manager >/dev/null 2>&1 || true
  exit 0
fi

if pgrep -x blueberry >/dev/null 2>&1; then
  pkill -x blueberry >/dev/null 2>&1 || true
  exit 0
fi

if pgrep -x gnome-control-center >/dev/null 2>&1; then
  pkill -x gnome-control-center >/dev/null 2>&1 || true
  exit 0
fi

if command -v blueman-manager >/dev/null 2>&1; then
  exec blueman-manager
fi

if command -v blueberry >/dev/null 2>&1; then
  exec blueberry
fi

if command -v gnome-control-center >/dev/null 2>&1; then
  exec gnome-control-center bluetooth
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Bluetooth manager not found" "Install blueman, blueberry, or gnome-control-center."
fi
