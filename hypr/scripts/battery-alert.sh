#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_RUNTIME_DIR:-/tmp}/battery-alert.last"
charge_state_file="${XDG_RUNTIME_DIR:-/tmp}/battery-charge-alert.last"

while sleep 60; do
  line="$(acpi -b 2>/dev/null | head -n1 || true)"
  [ -n "$line" ] || continue

  status="$(printf '%s\n' "$line" | sed -E 's/^.*: ([^,]+),.*$/\1/')"
  percent_raw="$(printf '%s\n' "$line" | grep -oE '[0-9]+%' | head -n1 || true)"
  percent="${percent_raw%\%}"
  [[ "$percent" =~ ^[0-9]+$ ]] || continue

  if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
    rm -f "$state_file"

    if [ "$percent" -ge 80 ]; then
      alerted="$(cat "$charge_state_file" 2>/dev/null || true)"
      if [ "$alerted" != "80" ] && command -v notify-send >/dev/null 2>&1; then
        notify-send -u normal "Battery ${percent}% (Charging)" "Unplug charger at 80% for battery health"
        printf '%s\n' "80" > "$charge_state_file"
      fi
    elif [ "$percent" -le 75 ]; then
      rm -f "$charge_state_file"
    fi

    continue
  fi

  rm -f "$charge_state_file"

  level=""
  urgency="normal"
  if [ "$percent" -le 5 ]; then
    level="5"
    urgency="critical"
  elif [ "$percent" -le 10 ]; then
    level="10"
    urgency="critical"
  elif [ "$percent" -le 20 ]; then
    level="20"
    urgency="normal"
  else
    rm -f "$state_file"
    continue
  fi

  last_level="$(cat "$state_file" 2>/dev/null || true)"
  [ "$last_level" = "$level" ] && continue
  printf '%s\n' "$level" > "$state_file"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u "$urgency" "Battery low: ${percent}%" "Connect charger"
  fi
done
