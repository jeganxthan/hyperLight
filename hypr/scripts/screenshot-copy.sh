#!/usr/bin/env bash
set -euo pipefail

for cmd in grim wl-copy; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    command -v notify-send >/dev/null 2>&1 && notify-send "Screenshot failed" "Missing command: $cmd"
    exit 1
  fi
done

dir="$HOME/pictures/screenshots"
mkdir -p "$dir"

file="$dir/screenshot-$(date +%Y%m%d-%H%M%S).png"

if ! grim "$file"; then
  command -v notify-send >/dev/null 2>&1 && notify-send "Screenshot failed" "grim could not capture screen"
  exit 1
fi

wl-copy --type image/png < "$file"

if command -v canberra-gtk-play >/dev/null 2>&1; then
  canberra-gtk-play -i camera-shutter -d "screenshot" >/dev/null 2>&1 || true
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Screenshot saved" "$file"
fi
