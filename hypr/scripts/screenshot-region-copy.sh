#!/usr/bin/env bash
set -euo pipefail

for cmd in grim slurp wl-copy; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    command -v notify-send >/dev/null 2>&1 && notify-send "Screenshot failed" "Missing command: $cmd"
    exit 1
  fi
done

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"

file="$dir/screenshot-$(date +%Y%m%d-%H%M%S)-region.png"

region="$(slurp)"
[ -n "${region:-}" ] || exit 0

if ! grim -g "$region" "$file"; then
  command -v notify-send >/dev/null 2>&1 && notify-send "Screenshot failed" "grim could not capture selected region"
  exit 1
fi

if ! wl-copy --type image/png < "$file"; then
  command -v notify-send >/dev/null 2>&1 && notify-send "Screenshot failed" "Could not copy image to clipboard"
  exit 1
fi

# Also copy to PRIMARY selection for middle-click paste workflows.
wl-copy --primary --type image/png < "$file" >/dev/null 2>&1 || true

# If cliphist is available, store immediately.
if command -v cliphist >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
  wl-paste --type image/png 2>/dev/null | cliphist store >/dev/null 2>&1 || true
fi

if command -v canberra-gtk-play >/dev/null 2>&1; then
  canberra-gtk-play -i camera-shutter -d "screenshot" >/dev/null 2>&1 || true
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Region screenshot saved" "$file"
fi
