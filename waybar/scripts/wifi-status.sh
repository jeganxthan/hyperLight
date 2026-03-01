#!/usr/bin/env bash
set -euo pipefail

json_escape() {
  printf '%s' "$1" | sed ':a;N;$!ba;s/\\/\\\\/g;s/"/\\"/g;s/\n/\\n/g'
}

if ! command -v nmcli >/dev/null 2>&1; then
  printf '{"text":" n/a","tooltip":"nmcli not found","class":"off"}\n'
  exit 0
fi

wifi_state="$(nmcli -t -f WIFI general 2>/dev/null | head -n1 || true)"
if [ "$wifi_state" != "enabled" ]; then
  printf '{"text":"󰖪 off","tooltip":"Wi-Fi is disabled\\nLeft click: open settings\\nRight click: toggle","class":"off"}\n'
  exit 0
fi

active_line="$(nmcli -t -f IN-USE,SSID,SIGNAL,RATE,BARS dev wifi list 2>/dev/null | awk -F: '$1=="*" {print; exit}')"
if [ -z "$active_line" ]; then
  printf '{"text":" on","tooltip":"Wi-Fi enabled (not connected)\\nLeft click: open settings\\nRight click: toggle","class":"on"}\n'
  exit 0
fi

ssid="$(printf '%s' "$active_line" | cut -d: -f2)"
signal="$(printf '%s' "$active_line" | cut -d: -f3)"
rate="$(printf '%s' "$active_line" | cut -d: -f4)"
bars="$(printf '%s' "$active_line" | cut -d: -f5)"

[ -n "$ssid" ] || ssid="(hidden)"
[ -n "$signal" ] || signal="?"
[ -n "$rate" ] || rate="n/a"
[ -n "$bars" ] || bars="n/a"

text=" ${signal}%"
tooltip="SSID: ${ssid}\nSignal: ${signal}%\nRate: ${rate}\nBars: ${bars}\nLeft click: open settings\nRight click: toggle"

printf '{"text":"%s","tooltip":"%s","class":"on"}\n' \
  "$(json_escape "$text")" \
  "$(json_escape "$tooltip")"

