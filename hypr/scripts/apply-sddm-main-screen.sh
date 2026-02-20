#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Run as root: sudo $0"
  exit 1
fi

mkdir -p /etc/sddm.conf.d

if [ -f /etc/sddm.conf.d/10-theme.conf ]; then
  cp /etc/sddm.conf.d/10-theme.conf "/etc/sddm.conf.d/10-theme.conf.bak_codex_$(date +%Y%m%d%H%M%S)"
fi

cat > /etc/sddm.conf.d/10-theme.conf <<'EOF'
[Theme]
Current=maya
CursorTheme=Breeze
EOF

theme_user="/usr/share/sddm/themes/maya/theme.conf.user"
if [ -f "$theme_user" ]; then
  cp "$theme_user" "${theme_user}.bak_codex_$(date +%Y%m%d%H%M%S)"
fi

cat > "$theme_user" <<'EOF'
[General]
primaryShade=#0a0e16
primaryLight=#132235
primaryDark=#06080d

primaryHue1=#14263b
primaryHue2=#102033
primaryHue3=#0c1725

accentShade=#1793d1
accentLight=#6cb6ff

accentHue1=#2ea4dc
accentHue2=#1793d1
accentHue3=#0f6f9f

normalText=#e6edf3

successText=#8bd49c
failureText=#ff6b6b
warningText=#ffd580

rebootColor=#f59e0b
powerColor=#ef4444
EOF

echo "SDDM main screen theme applied (maya + Arch-blue palette)."
echo "Restart to see it on next login screen, or run: sudo systemctl restart sddm"
