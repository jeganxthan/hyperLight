#!/usr/bin/env bash
set -euo pipefail

if ! command -v cliphist >/dev/null 2>&1; then
  exit 0
fi

# Clear clipboard history database.
cliphist wipe >/dev/null 2>&1 || true

