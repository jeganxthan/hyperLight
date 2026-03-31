#!/usr/bin/env bash
set -euo pipefail

pid_file="${XDG_RUNTIME_DIR:-/tmp}/gsr.pid"
last_file="${XDG_RUNTIME_DIR:-/tmp}/gsr.last"
out_dir="$HOME/Videos/Recordings"
mkdir -p "$out_dir"
waybar_signal=8

notify() {
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send "$1" "$2" >/dev/null 2>&1 || true
}

refresh_waybar() {
  pkill "-RTMIN+${waybar_signal}" waybar >/dev/null 2>&1 || true
}

find_running_pid() {
  local pid=""

  if [ -f "$pid_file" ]; then
    pid="$(cat "$pid_file" 2>/dev/null || true)"
    if [ -n "$pid" ] && kill -0 "$pid" >/dev/null 2>&1; then
      printf '%s\n' "$pid"
      return 0
    fi
  fi

  pgrep -n -x gpu-screen-rec 2>/dev/null || true
}

stop_recording() {
  local pid="$1"
  local out=""
  local waited=0

  if [ -n "$pid" ] && kill -0 "$pid" >/dev/null 2>&1; then
    # gpu-screen-recorder saves on SIGINT
    kill -INT "$pid" >/dev/null 2>&1 || true
    while kill -0 "$pid" >/dev/null 2>&1; do
      sleep 0.1
      waited=$((waited + 1))
      if [ "$waited" -ge 30 ]; then
        kill -TERM "$pid" >/dev/null 2>&1 || true
        break
      fi
    done
  else
    pkill -INT -x gpu-screen-rec >/dev/null 2>&1 || true
    while pgrep -x gpu-screen-rec >/dev/null 2>&1; do
      sleep 0.1
      waited=$((waited + 1))
      if [ "$waited" -ge 30 ]; then
        pkill -x gpu-screen-rec >/dev/null 2>&1 || true
        break
      fi
    done
  fi

  rm -f "$pid_file"
  out="$(cat "$last_file" 2>/dev/null || true)"
  refresh_waybar
  [ -n "$out" ] && notify "Screen recording saved" "$out"
}

# ── If already recording, stop ──────────────────────────────
running_pid="$(find_running_pid)"
if [ -n "$running_pid" ]; then
  stop_recording "$running_pid"
  exit 0
fi

rm -f "$pid_file"

# ── Check tool is installed ─────────────────────────────────
if ! command -v gpu-screen-recorder >/dev/null 2>&1; then
  notify "Screen recorder missing" "Install with: sudo pacman -S gpu-screen-recorder"
  exit 1
fi

# ── Start recording ─────────────────────────────────────────
ts="$(date +%Y-%m-%d_%H-%M-%S)"
out_file="$out_dir/screenrec_${ts}.mp4"
printf '%s\n' "$out_file" > "$last_file"

# Build command — record the whole screen with audio
cmd=(
  gpu-screen-recorder
  -w screen
  -f 60
  -c mp4
  -o "$out_file"
)

# Add audio capture if pactl is available
if command -v pactl >/dev/null 2>&1; then
  default_source="$(pactl get-default-source 2>/dev/null || true)"
  if [ -n "$default_source" ]; then
    cmd+=(-a "$default_source")
  fi
fi

setsid "${cmd[@]}" >/tmp/gsr.log 2>&1 &
pid="$!"
sleep 1.5

if ! kill -0 "$pid" >/dev/null 2>&1; then
  rm -f "$pid_file"
  notify "Screen recording failed" "See /tmp/gsr.log"
  refresh_waybar
  exit 1
fi

printf '%s\n' "$pid" > "$pid_file"
refresh_waybar
notify "Screen recording started" "Saving to $out_file"
