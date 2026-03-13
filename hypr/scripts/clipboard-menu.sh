#!/usr/bin/env bash
set -euo pipefail

# Toggle behavior: if the Clipboard menu is already open, close it.
if command -v pgrep >/dev/null 2>&1 && command -v pkill >/dev/null 2>&1; then
  if pgrep -af 'wofi.*--dmenu.*--prompt[= ]Clipboard' >/dev/null 2>&1; then
    pkill -f 'wofi.*--dmenu.*--prompt[= ]Clipboard' >/dev/null 2>&1 || true
    exit 0
  fi
fi

for cmd in cliphist wofi wl-copy; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    command -v notify-send >/dev/null 2>&1 && notify-send "Clipboard failed" "Missing command: $cmd"
    exit 1
  fi
done

mapfile -t entries < <(cliphist list)
[ "${#entries[@]}" -gt 0 ] || {
  command -v notify-send >/dev/null 2>&1 && notify-send "Clipboard" "No clipboard history"
  exit 0
}

display_entry() {
  local line="$1"
  # cliphist list format starts with internal numeric id; hide it in UI.
  printf '%s' "$line" | sed -E 's/^[0-9]+[[:space:]]+//'
}

selection="$(
  for i in "${!entries[@]}"; do
    printf '%d  %s\n' "$((i + 1))" "$(display_entry "${entries[$i]}")"
  done | wofi --dmenu --style "$HOME/.config/wofi/style.css" --prompt "Clipboard"
)"
[ -n "${selection:-}" ] || exit 0

index="${selection%% *}"
if ! [[ "$index" =~ ^[0-9]+$ ]]; then
  exit 0
fi

if [ "$index" -lt 1 ] || [ "$index" -gt "${#entries[@]}" ]; then
  exit 0
fi

picked="${entries[$((index - 1))]}"
printf '%s' "$picked" | cliphist decode | wl-copy
