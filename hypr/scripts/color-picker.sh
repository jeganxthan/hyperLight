#!/usr/bin/env bash
set -euo pipefail

if ! command -v hyprpicker >/dev/null 2>&1; then
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Hyprpicker not found" "Install with: sudo pacman -S hyprpicker"
  fi
  exit 1
fi

# -a copies the picked color to clipboard.
picked="$(hyprpicker -a 2>/dev/null || true)"
picked="$(printf '%s' "$picked" | tail -n1 | tr -d '\r')"

if [ -z "$picked" ] && command -v wl-paste >/dev/null 2>&1; then
  picked="$(wl-paste -n 2>/dev/null || true)"
fi

if [[ "$picked" =~ ^#?[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$ ]]; then
  if [[ "$picked" != \#* ]]; then
    picked="#$picked"
  fi
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Color picked" "$picked copied to clipboard"
  fi
  exit 0
fi

# Canceled pick or unsupported output format.
exit 0
