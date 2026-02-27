#!/usr/bin/env bash
set -euo pipefail

stamp_file="${XDG_RUNTIME_DIR:-/tmp}/mute-toggle.last"
now_ms="$(date +%s%3N)"
last_ms="$(cat "$stamp_file" 2>/dev/null || echo 0)"

# Debounce duplicate bindings (symbol + code fallback).
if [ $((now_ms - last_ms)) -lt 350 ]; then
  exit 0
fi
printf '%s\n' "$now_ms" > "$stamp_file"

# Primary path: swayosd handles mute + OSD in one call.
if command -v swayosd-client >/dev/null 2>&1; then
  if swayosd-client --output-volume mute-toggle >/dev/null 2>&1; then
    exit 0
  fi
fi

# Fallback path if swayosd-client is unavailable/fails.
if command -v wpctl >/dev/null 2>&1; then
  if wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null 2>&1; then
    exit 0
  fi
fi

# Secondary fallback for PulseAudio-compatible setups.
if command -v pactl >/dev/null 2>&1; then
  if pactl set-sink-mute @DEFAULT_SINK@ toggle >/dev/null 2>&1; then
    exit 0
  fi
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Mute failed" "Neither swayosd-client nor wpctl worked" >/dev/null 2>&1 || true
fi
