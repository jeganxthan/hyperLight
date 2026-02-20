#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Run as root: sudo $0"
  exit 1
fi

user_name="${SUDO_USER:-${1:-}}"
if [ -z "$user_name" ]; then
  echo "Usage: sudo $0 <username>"
  echo "Example: sudo $0 $USER"
  exit 1
fi

pam_file="/etc/pam.d/system-auth"
backup_file="${pam_file}.bak_codex_$(date +%Y%m%d%H%M%S)"
cp "$pam_file" "$backup_file"
echo "Backup created: $backup_file"

# Ensure fingerprint is tried first (once), then fall back to password prompt.
if grep -q 'pam_fprintd.so' "$pam_file"; then
  sed -i 's|^auth[[:space:]]\+\[success=1 default=ignore\][[:space:]]\+pam_fprintd\.so.*$|auth       [success=1 default=ignore]  pam_fprintd.so max_tries=1 timeout=5|' "$pam_file"
else
  awk '
    /^auth[[:space:]]+\[success=1 default=bad\][[:space:]]+pam_unix\.so/ && !done {
      print "auth       [success=1 default=ignore]  pam_fprintd.so max_tries=1 timeout=5"
      done=1
    }
    { print }
  ' "$pam_file" > /tmp/system-auth.codex.new
  install -m 644 /tmp/system-auth.codex.new "$pam_file"
fi

# Ensure password prompt fallback works after fingerprint fails.
sed -i 's|pam_unix.so[[:space:]]\+try_first_pass[[:space:]]\+nullok|pam_unix.so          nullok|' "$pam_file"

echo "Updated $pam_file for fingerprint -> password fallback."

echo "Re-enrolling fingerprint for user: $user_name"
fprintd-delete "$user_name" || true
fprintd-enroll "$user_name"

echo "Done. Test with: sudo -k && sudo true"
