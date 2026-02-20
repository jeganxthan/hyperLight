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

[ -n "$wallpaper_dir" ] || exit 1

mapfile -d '' images < <(find "$wallpaper_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0)
[ "${#images[@]}" -gt 0 ] || exit 1

selection="$(printf '%s\n' "${images[@]}" | sed "s|^$wallpaper_dir/||" | sort | wofi --dmenu --prompt "Select Wallpaper")"
[ -n "${selection:-}" ] || exit 0

wallpaper="$wallpaper_dir/$selection"
[ -f "$wallpaper" ] || exit 1

if command -v hyprctl >/dev/null 2>&1; then
  pgrep -x hyprpaper >/dev/null 2>&1 || (hyprpaper >/dev/null 2>&1 & sleep 0.4)
  hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1 || true
  hyprctl hyprpaper wallpaper ",$wallpaper" >/dev/null 2>&1 || true
  hyprctl hyprpaper unload unused >/dev/null 2>&1 || true
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Wallpaper changed" "$selection"
fi
