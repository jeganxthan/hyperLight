#!/usr/bin/env bash
set -euo pipefail

# Force native Wayland for sharper rendering on scaled displays.
exec /opt/postman/Postman \
  --enable-features=UseOzonePlatform \
  --ozone-platform=wayland \
  --ozone-platform-hint=auto \
  "$@"
