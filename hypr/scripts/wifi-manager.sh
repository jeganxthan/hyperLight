#!/usr/bin/env bash
set -euo pipefail

wofi_style="${HOME}/.config/wofi/style.css"
prompt="Wi-Fi"
menu_match="wofi --dmenu --prompt ${prompt}"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$1" "${2:-}"
  fi
}

if ! command -v nmcli >/dev/null 2>&1; then
  notify "Wi-Fi manager" "nmcli is not installed."
  exit 1
fi

if ! command -v wofi >/dev/null 2>&1; then
  notify "Wi-Fi manager" "wofi is not installed."
  exit 1
fi

if pgrep -af "$menu_match" >/dev/null 2>&1; then
  pkill -f "$menu_match" >/dev/null 2>&1 || true
  exit 0
fi

wifi_state="$(nmcli -t -f WIFI g 2>/dev/null | head -n1 || true)"
active_ssid="$(nmcli -t -f ACTIVE,SSID dev wifi list 2>/dev/null | awk -F: '$1=="yes" {print $2; exit}')"

menu_input() {
  wofi --dmenu \
    --prompt "$prompt" \
    --style "$wofi_style" \
    --width 820 \
    --height 560 \
    --hide-scroll
}

password_input() {
  wofi --dmenu \
    --prompt "Password" \
    --style "$wofi_style" \
    --width 520 \
    --height 220 \
    --password
}

open_advanced() {
  if command -v gnome-control-center >/dev/null 2>&1; then
    exec gnome-control-center wifi
  fi
  if command -v nm-connection-editor >/dev/null 2>&1; then
    exec nm-connection-editor
  fi
  if command -v nmtui >/dev/null 2>&1 && command -v kitty >/dev/null 2>&1; then
    exec kitty --class nmtui-wifi --title "Wi-Fi Settings" sh -c "nmtui"
  fi
  notify "Wi-Fi manager" "No advanced Wi-Fi settings app found."
  exit 1
}

build_menu() {
  if [ "$wifi_state" = "enabled" ]; then
    printf 'Disable Wi-Fi\n'
  else
    printf 'Enable Wi-Fi\n'
  fi

  printf 'Rescan Networks\n'

  if [ -n "$active_ssid" ]; then
    printf 'Disconnect: %s\n' "$active_ssid"
  fi

  printf 'Advanced Settings\n'
  printf 'Connect Hidden Network\n'

  if [ "$wifi_state" != "enabled" ]; then
    return
  fi

  networks="$(
    nmcli --rescan yes -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null || true
  )"
  if [ -z "$networks" ]; then
    networks="$(
      nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi 2>/dev/null || true
    )"
  fi

  if [ -z "$networks" ]; then
    printf 'No networks found\n'
    return
  fi

  printf '%s\n' "$networks" | awk -F: '
    {
      ssid = $2
      signal = $3
      security = $4
      if (ssid == "") next
      if (seen[ssid]++) next
      if (security == "" || security == "--") security = "open"
      marker = ($1 == "*") ? "Connected" : "Wi-Fi"
      printf "%s  %s  %s%%  [%s]\n", marker, ssid, signal, security
    }
  '
}

connect_network() {
  local selection="$1"
  local ssid security password

  ssid="$(printf '%s\n' "$selection" | sed -E 's/^(Connected|Wi-Fi)  (.*)  [0-9]+%  \[(.*)\]$/\2/')"
  security="$(printf '%s\n' "$selection" | sed -E 's/^(Connected|Wi-Fi)  (.*)  [0-9]+%  \[(.*)\]$/\3/')"

  if [ -z "$ssid" ] || [ "$ssid" = "$selection" ]; then
    notify "Wi-Fi manager" "Could not parse selected network."
    exit 1
  fi

  if nmcli --wait 15 device wifi connect "$ssid" >/tmp/wifi-manager.log 2>&1; then
    notify "Wi-Fi connected" "$ssid"
    exit 0
  fi

  if [ "$security" != "open" ]; then
    password="$(password_input || true)"
    [ -n "${password:-}" ] || exit 0

    if nmcli --wait 20 device wifi connect "$ssid" password "$password" >/tmp/wifi-manager.log 2>&1; then
      notify "Wi-Fi connected" "$ssid"
      exit 0
    fi
  fi

  notify "Wi-Fi connection failed" "$(tail -n1 /tmp/wifi-manager.log 2>/dev/null || echo "$ssid")"
  exit 1
}

connect_hidden() {
  local ssid password

  ssid="$(
    wofi --dmenu \
      --prompt "Hidden SSID" \
      --style "$wofi_style" \
      --width 520 \
      --height 220 || true
  )"

  [ -n "${ssid:-}" ] || exit 0

  password="$(password_input || true)"
  [ -n "${password:-}" ] || exit 0

  if nmcli --wait 20 dev wifi connect "$ssid" password "$password" hidden yes >/tmp/wifi-manager.log 2>&1; then
    notify "Wi-Fi connected" "$ssid"
    exit 0
  fi

  notify "Wi-Fi connection failed" "$(tail -n1 /tmp/wifi-manager.log 2>/dev/null || echo "$ssid")"
  exit 1
}

selection="$(build_menu | menu_input)"
[ -n "${selection:-}" ] || exit 0

case "$selection" in
  "Enable Wi-Fi")
    nmcli radio wifi on
    notify "Wi-Fi enabled"
    ;;
  "Disable Wi-Fi")
    nmcli radio wifi off
    notify "Wi-Fi disabled"
    ;;
  "Rescan Networks")
    nmcli device wifi rescan >/dev/null 2>&1 || true
    notify "Wi-Fi" "Scan requested."
    ;;
  "Advanced Settings")
    open_advanced
    ;;
  "Connect Hidden Network")
    connect_hidden
    ;;
  "Disconnect: "*)
    if [ -n "$active_ssid" ]; then
      nmcli connection down id "$active_ssid" >/tmp/wifi-manager.log 2>&1 || true
      notify "Wi-Fi disconnected" "$active_ssid"
    fi
    ;;
  Connected*"["*"]"|Wi-Fi*"["*"]")
    connect_network "$selection"
    ;;
  "No networks found")
    notify "Wi-Fi" "No networks found. Try Rescan Networks."
    ;;
esac
