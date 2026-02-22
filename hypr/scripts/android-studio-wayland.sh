#!/usr/bin/env bash
set -euo pipefail

# Force native Wayland backend for JetBrains Runtime to avoid XWayland blur.
export _JAVA_AWT_WM_NONREPARENTING=1
exec /opt/android-studio/bin/studio \
  -Dawt.toolkit.name=WLToolkit \
  "$@"
