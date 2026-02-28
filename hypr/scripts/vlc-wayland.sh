#!/usr/bin/env bash
set -euo pipefail

# Force native Wayland for VLC with crisp Qt scaling on fractional displays.
exec env -u DISPLAY \
  XDG_SESSION_TYPE=wayland \
  QT_QPA_PLATFORM=wayland \
  QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor \
  /usr/bin/vlc \
  --no-xlib \
  "$@"
