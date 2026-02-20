#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Run as root: sudo $0"
  exit 1
fi

target="/etc/pam.d/hyprlock"
backup="${target}.bak_codex_$(date +%Y%m%d%H%M%S)"
cp "$target" "$backup"
echo "Backup created: $backup"

cat > "$target" <<'EOF'
#%PAM-1.0
auth       sufficient   pam_fprintd.so
auth       include      system-login

account    include      system-login
password   include      system-login
session    include      system-login
EOF

echo "Applied fingerprint-first PAM config to $target"
