#!/usr/bin/env bash
set -euo pipefail

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$1" "${2:-}" >/dev/null 2>&1 || true
  fi
}

if ! command -v powerprofilesctl >/dev/null 2>&1; then
  notify "Performance mode unavailable" "Install and enable power-profiles-daemon."
  exit 1
fi

current="$(powerprofilesctl get 2>/dev/null || true)"

case "$current" in
  power-saver)
    next="balanced"
    label="Balanced"
    ;;
  balanced)
    next="performance"
    label="Performance"
    ;;
  performance)
    next="power-saver"
    label="Power Saver"
    ;;
  *)
    next="balanced"
    label="Balanced"
    ;;
esac

if powerprofilesctl set "$next" >/dev/null 2>&1; then
  notify "Power profile changed" "$label"
  exit 0
fi

notify "Performance mode failed" "Could not switch power profile."
exit 1
