#!/usr/bin/env bash
set -euo pipefail

# Manual lock path: if still locked after 30s, suspend (not shutdown).
/home/jegan/.config/hypr/scripts/lock-screen.sh 30
