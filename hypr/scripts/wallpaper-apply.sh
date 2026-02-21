#!/usr/bin/env bash
set -euo pipefail

state_file="$HOME/.config/hypr/.current_wallpaper"
hyprpaper_conf="$HOME/.config/hypr/hyprpaper.conf"

pick_first_image() {
  local dirs=(
    "$HOME/pictures/wallpapers"
    "$HOME/pictures/Wallpapers"
    "$HOME/pictures"
    "$HOME/Pictures/Wallpapers"
    "$HOME/Pictures/wallpapers"
    "$HOME/Pictures"
  )
  local d
  for d in "${dirs[@]}"; do
    [ -d "$d" ] || continue
    find "$d" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | head -n 1
    return 0
  done
  return 1
}

wallpaper="${1:-}"
if [ -z "$wallpaper" ] && [ -f "$state_file" ]; then
  wallpaper="$(cat "$state_file" 2>/dev/null || true)"
fi
if [ -z "$wallpaper" ]; then
  wallpaper="$(pick_first_image || true)"
fi
[ -n "$wallpaper" ] || exit 1
[ -f "$wallpaper" ] || exit 1

mkdir -p "$(dirname "$state_file")"
printf '%s\n' "$wallpaper" > "$state_file"

cat > "$hyprpaper_conf" <<EOF
splash = false
preload = $wallpaper
wallpaper = ,$wallpaper
EOF

if command -v hyprctl >/dev/null 2>&1; then
  pgrep -x hyprpaper >/dev/null 2>&1 || (hyprpaper >/dev/null 2>&1 & sleep 0.5)
  hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1 || true
  hyprctl hyprpaper wallpaper ",$wallpaper" >/dev/null 2>&1 || true
  hyprctl hyprpaper unload unused >/dev/null 2>&1 || true
fi
