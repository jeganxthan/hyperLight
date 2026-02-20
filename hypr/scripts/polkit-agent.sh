#!/usr/bin/env bash
set -u

agent=""
for candidate in \
  /usr/lib/lxqt-policykit-agent/lxqt-policykit-agent \
  /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
  /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 \
  /usr/lib/xfce-polkit/xfce-polkit \
  /usr/lib/polkit-kde-authentication-agent-1
do
  if [ -x "$candidate" ]; then
    agent="$candidate"
    break
  fi
done

[ -n "$agent" ] || exit 1

while true; do
  "$agent"
  sleep 1
done
