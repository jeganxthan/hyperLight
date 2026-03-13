#!/usr/bin/env bash
set -euo pipefail

# Keep Chrome on default GTK font without touching global GTK styling.
chrome_env_home="$HOME/.config/chrome-gtk-default"
gtk3_dir="$chrome_env_home/gtk-3.0"
gtk4_dir="$chrome_env_home/gtk-4.0"

mkdir -p "$gtk3_dir" "$gtk4_dir"

if [ ! -f "$gtk3_dir/settings.ini" ]; then
  cat >"$gtk3_dir/settings.ini" <<'EOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-font-name=Noto Sans 11
gtk-icon-theme-name=Papirus-Dark
EOF
fi

if [ ! -f "$gtk4_dir/settings.ini" ]; then
  cat >"$gtk4_dir/settings.ini" <<'EOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-font-name=Noto Sans 11
gtk-icon-theme-name=Papirus-Dark
EOF
fi

exec env \
  XDG_CONFIG_HOME="$chrome_env_home" \
  /usr/bin/google-chrome-stable \
  --user-data-dir="$HOME/.config/google-chrome" \
  "$@"

