#!/usr/bin/env bash
set -euo pipefail

# Open Wi-Fi configuration UI (best available option).
if command -v nm-connection-editor >/dev/null 2>&1; then
  exec nm-connection-editor
fi

if command -v gnome-control-center >/dev/null 2>&1; then
  exec gnome-control-center wifi
fi

if command -v nmtui >/dev/null 2>&1; then
  exec kitty --class nmtui-wifi --title "Wi-Fi Settings" sh -c "nmtui"
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Wi-Fi settings not found" "Install network-manager-applet or gnome-control-center."
fi

