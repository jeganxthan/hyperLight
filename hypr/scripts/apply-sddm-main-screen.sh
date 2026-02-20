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

theme_name="maldives"
[ -d /usr/share/sddm/themes/sugar-candy ] && theme_name="sugar-candy"
[ -d /usr/share/sddm/themes/sugar-candy-git ] && theme_name="sugar-candy-git"

cat > /etc/sddm.conf.d/10-theme.conf <<EOF
[Theme]
Current=${theme_name}
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

# Optional theme tuning for maya only.
if [ "$theme_name" = "maya" ]; then
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
fi

# PAM for main login screen (SDDM): password-only.
pam_file="/etc/pam.d/sddm"
if [ -f "$pam_file" ]; then
  cp "$pam_file" "${pam_file}.bak_codex_$(date +%Y%m%d%H%M%S)"
fi

cat > "$pam_file" <<'EOF'
#%PAM-1.0
auth       include      system-login

account    include      system-login
password   include      system-login
session    include      system-login
EOF

echo "Applied:"
echo "- SDDM theme: ${theme_name}"
echo "- Remember last user/session"
echo "- PAM: password-only on SDDM (fingerprint disabled for main login screen)"
echo "- No theme QML patching"
if [ "$theme_name" != "sugar-candy" ] && [ "$theme_name" != "sugar-candy-git" ]; then
  echo "Tip: install a richer SDDM theme package (e.g. sugar-candy) and rerun this script."
fi
echo "Restart to see it on next login screen, or run: sudo systemctl restart sddm"
