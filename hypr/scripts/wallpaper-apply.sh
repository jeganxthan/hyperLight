#!/usr/bin/env bash
set -euo pipefail

state_file="$HOME/.config/hypr/.current_wallpaper"
lock_wallpaper_link="$HOME/.config/hypr/.current_wallpaper_lock"
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
    find "$d" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | head -n 1
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
ln -sfn "$wallpaper" "$lock_wallpaper_link"

if [ -x "$HOME/.config/hypr/scripts/rofi-wall-cache.sh" ]; then
  "$HOME/.config/hypr/scripts/rofi-wall-cache.sh" "$wallpaper" >/dev/null 2>&1 || true
fi

if [ -x "$HOME/.config/hypr/scripts/apply-swaync-ui.sh" ]; then
  "$HOME/.config/hypr/scripts/apply-swaync-ui.sh" >/dev/null 2>&1 || true
fi

if [[ "$wallpaper" == *.gif ]]; then
  if command -v mpvpaper >/dev/null 2>&1; then
    # Kill any existing mpvpaper and hyprpaper instances
    pkill -x mpvpaper >/dev/null 2>&1 || true
    pkill -x hyprpaper >/dev/null 2>&1 || true
    
    # Get primary monitor name
    # eDP-1 is a fallback
    monitor=$(hyprctl monitors -j | jq -r '.[0].name' || echo "eDP-1")
    
    # Start mpvpaper in the background
    mpvpaper -vs -o "--no-audio --loop-file=inf --hwdec=auto" "$monitor" "$wallpaper" >/dev/null 2>&1 &
    
    exit 0
  fi
fi

# Not a GIF, or mpvpaper not installed: revert to hyprpaper
pkill -x mpvpaper >/dev/null 2>&1 || true
pgrep -x hyprpaper >/dev/null 2>&1 || (hyprpaper >/dev/null 2>&1 & sleep 0.5)

cat > "$hyprpaper_conf" <<EOF
splash = false
preload = $wallpaper
wallpaper = ,$wallpaper
EOF

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1 || true
  hyprctl hyprpaper wallpaper ",$wallpaper" >/dev/null 2>&1 || true
  hyprctl hyprpaper unload unused >/dev/null 2>&1 || true
fi
