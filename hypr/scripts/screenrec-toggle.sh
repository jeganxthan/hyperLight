#!/usr/bin/env bash
set -euo pipefail

pid_file="${XDG_RUNTIME_DIR:-/tmp}/wf-recorder.pid"
last_file="${XDG_RUNTIME_DIR:-/tmp}/wf-recorder.last"
out_dir="$HOME/Videos/Recordings"
mkdir -p "$out_dir"

notify() {
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send "$1" "$2" >/dev/null 2>&1 || true
}

if [ -f "$pid_file" ]; then
  pid="$(cat "$pid_file" 2>/dev/null || true)"
  if [ -n "$pid" ] && kill -0 "$pid" >/dev/null 2>&1; then
    kill -INT "$pid" >/dev/null 2>&1 || kill "$pid" >/dev/null 2>&1 || true
    rm -f "$pid_file"
    out="$(cat "$last_file" 2>/dev/null || true)"
    [ -n "$out" ] && notify "Screen recording saved" "$out"
    exit 0
  fi
  rm -f "$pid_file"
fi

if ! command -v wf-recorder >/dev/null 2>&1; then
  notify "Screen recorder missing" "Install with: sudo pacman -S wf-recorder"
  exit 1
fi

ts="$(date +%Y-%m-%d_%H-%M-%S)"
out_file="$out_dir/screenrec_${ts}.mp4"
printf '%s\n' "$out_file" > "$last_file"

default_source=""
if command -v pactl >/dev/null 2>&1; then
  default_source="$(pactl get-default-source 2>/dev/null || true)"
fi

if [ -n "$default_source" ]; then
  wf-recorder -f "$out_file" -a -D "$default_source" >/tmp/wf-recorder.log 2>&1 &
else
  wf-recorder -f "$out_file" >/tmp/wf-recorder.log 2>&1 &
fi

pid="$!"
printf '%s\n' "$pid" > "$pid_file"
notify "Screen recording started" "Saving to $out_file"
