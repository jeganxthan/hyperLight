#!/usr/bin/env bash
set -euo pipefail

json_escape() {
  printf '%s' "$1" | sed ':a;N;$!ba;s/\\/\\\\/g;s/"/\\"/g;s/\n/\\n/g'
}

if ! command -v bluetoothctl >/dev/null 2>&1; then
  printf '{"text":" n/a","tooltip":"bluetoothctl not found","class":"off"}\n'
  exit 0
fi

show_output="$(bluetoothctl show 2>/dev/null || true)"
if [ -z "$show_output" ]; then
  printf '{"text":" n/a","tooltip":"No Bluetooth controller found","class":"off"}\n'
  exit 0
fi

powered="$(printf '%s\n' "$show_output" | awk -F': ' '/Powered:/{print $2; exit}')"
alias_name="$(printf '%s\n' "$show_output" | awk -F': ' '/Alias:/{print $2; exit}')"
[ -n "$alias_name" ] || alias_name="Unknown"

if [ "$powered" != "yes" ]; then
  tooltip="Adapter: $alias_name\nStatus: off"
  printf '{"text":" off","tooltip":"%s","class":"off"}\n' "$(json_escape "$tooltip")"
  exit 0
fi

connected_devices=()
while read -r line; do
  [ -n "$line" ] || continue
  mac="${line#Device }"
  mac="${mac%% *}"
  name="${line#Device $mac }"
  info="$(bluetoothctl info "$mac" 2>/dev/null || true)"
  if printf '%s\n' "$info" | grep -q "Connected: yes"; then
    connected_devices+=("$name")
  fi
done < <(bluetoothctl devices 2>/dev/null || true)

count="${#connected_devices[@]}"
tooltip="Adapter: $alias_name\nStatus: on\nConnected: $count"

if [ "$count" -gt 0 ]; then
  device_list="$(printf '%s\n' "${connected_devices[@]}")"
  tooltip="$tooltip\nDevices:\n$device_list"
fi

if [ "$count" -gt 0 ]; then
  text=" $count"
  class="on"
else
  text=" on"
  class="on"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
  "$(json_escape "$text")" \
  "$(json_escape "$tooltip")" \
  "$class"
