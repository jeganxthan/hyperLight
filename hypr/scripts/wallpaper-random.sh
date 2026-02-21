#!/usr/bin/env bash
set -euo pipefail

dirs=(
  "$HOME/pictures/wallpapers"
  "$HOME/pictures/Wallpapers"
  "$HOME/pictures"
  "$HOME/Pictures/Wallpapers"
  "$HOME/Pictures/wallpapers"
  "$HOME/Pictures"
)

wallpaper_dir=""
for d in "${dirs[@]}"; do
  if [ -d "$d" ]; then
    wallpaper_dir="$d"
    break
  fi
done

if [ -z "$wallpaper_dir" ]; then
  exit 1
fi

mapfile -d '' images < <(find "$wallpaper_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0)
[ "${#images[@]}" -gt 0 ] || exit 1

wallpaper="$(printf '%s\n' "${images[@]}" | shuf -n 1)"

if [ -x "$HOME/.config/hypr/scripts/wallpaper-apply.sh" ]; then
  "$HOME/.config/hypr/scripts/wallpaper-apply.sh" "$wallpaper"
  exit 0
fi

if command -v swww >/dev/null 2>&1; then
  pgrep -x swww-daemon >/dev/null 2>&1 || (swww-daemon >/dev/null 2>&1 & sleep 0.4)
  swww img "$wallpaper" --transition-type grow --transition-duration 1 >/dev/null 2>&1
fi
