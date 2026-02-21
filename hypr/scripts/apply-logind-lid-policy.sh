#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Run as root: sudo $0"
  exit 1
fi

mkdir -p /etc/systemd/logind.conf.d
target="/etc/systemd/logind.conf.d/50-lid-suspend.conf"

cat > "$target" <<'EOF'
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
EOF

# Avoid hard restart because it can terminate the active graphical session.
systemctl reload-or-restart systemd-logind
echo "Applied lid-close policy in $target."
echo "Used reload-or-restart for systemd-logind (safer for active sessions)."
