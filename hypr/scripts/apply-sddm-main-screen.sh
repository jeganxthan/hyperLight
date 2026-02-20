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

if [ -f /etc/sddm.conf.d/20-users.conf ]; then
  cp /etc/sddm.conf.d/20-users.conf "/etc/sddm.conf.d/20-users.conf.bak_codex_$(date +%Y%m%d%H%M%S)"
fi

cat > /etc/sddm.conf.d/20-users.conf <<'EOF'
[Users]
RememberLastUser=true
RememberLastSession=true
MinimumUid=1000
MaximumUid=60513
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

# PAM: fingerprint first, fallback to password.
pam_file="/etc/pam.d/sddm"
if [ -f "$pam_file" ]; then
  cp "$pam_file" "${pam_file}.bak_codex_$(date +%Y%m%d%H%M%S)"
fi

cat > "$pam_file" <<'EOF'
#%PAM-1.0
auth       sufficient   pam_fprintd.so
auth       include      system-login

account    include      system-login
password   include      system-login
session    include      system-login
EOF

# Theme tweak: prefill last user in maya username box so login does not keep asking username.
main_qml="/usr/share/sddm/themes/maya/Main.qml"
if [ -f "$main_qml" ]; then
  cp "$main_qml" "${main_qml}.bak_codex_$(date +%Y%m%d%H%M%S)"
  if ! grep -q "text[[:space:]]*:[[:space:]]*userModel.lastUser" "$main_qml"; then
    awk '
      /id[[:space:]]*:[[:space:]]*maya_username/ && !done {
        print $0
        print ""
        print "        text    : userModel.lastUser"
        done=1
        next
      }
      { print }
    ' "$main_qml" > /tmp/maya-main.qml.codex
    install -m 644 /tmp/maya-main.qml.codex "$main_qml"
  fi
fi

echo "Applied:"
echo "- SDDM maya theme + colors"
echo "- Remember last user/session"
echo "- PAM fingerprint first, password fallback"
echo "- Prefill username with last logged in user"
echo "Restart to see it on next login screen, or run: sudo systemctl restart sddm"
