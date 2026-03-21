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

rofi_theme="${HOME}/.config/rofi/themes/wallpaper-grid.rasi"
menu_match="rofi -dmenu -i -p Wallpaper Picker -theme $rofi_theme"

# Toggle behavior: if this picker is already open, close it.
if pgrep -af "$menu_match" >/dev/null 2>&1; then
  pkill -f "$menu_match" >/dev/null 2>&1 || true
  exit 0
fi

mapfile -d '' images < <(
  find "$wallpaper_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | sort -z
)
[ "${#images[@]}" -gt 0 ] || exit 1

selection="$(
  {
    for img in "${images[@]}"; do
      rel="${img#"$wallpaper_dir/"}"
      # Rofi icon syntax: name\0icon\x1f/path/to/icon
      printf '%s\0icon\x1f%s\n' "$rel" "$img"
    done
  } | rofi -dmenu -i -p "Wallpaper Picker" \
      -theme "$rofi_theme" \
      -show-icons
)"
[ -n "${selection:-}" ] || exit 0

wallpaper="$wallpaper_dir/$selection"
[ -f "$wallpaper" ] || exit 1

if [ -x "$HOME/.config/hypr/scripts/wallpaper-apply.sh" ]; then
  "$HOME/.config/hypr/scripts/wallpaper-apply.sh" "$wallpaper"
elif command -v hyprctl >/dev/null 2>&1; then
  pgrep -x hyprpaper >/dev/null 2>&1 || (hyprpaper >/dev/null 2>&1 & sleep 0.4)
  hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1 || true
  hyprctl hyprpaper wallpaper ",$wallpaper" >/dev/null 2>&1 || true
  hyprctl hyprpaper unload unused >/dev/null 2>&1 || true
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Wallpaper changed" "$selection"
fi
