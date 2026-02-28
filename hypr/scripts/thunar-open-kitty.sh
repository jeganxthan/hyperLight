#!/usr/bin/env bash
set -euo pipefail

target="${1:-$PWD}"

if [ -f "$target" ]; then
  target="$(dirname "$target")"
fi

[ -d "$target" ] || target="$HOME"

exec kitty --directory "$target"

