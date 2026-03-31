#!/usr/bin/env bash
set -euo pipefail

pid_file="${XDG_RUNTIME_DIR:-/tmp}/gsr.pid"
last_file="${XDG_RUNTIME_DIR:-/tmp}/gsr.last"

pid=""
if [ -f "$pid_file" ]; then
  pid="$(cat "$pid_file" 2>/dev/null || true)"
fi

if [ -n "$pid" ] && kill -0 "$pid" >/dev/null 2>&1; then
  out="$(cat "$last_file" 2>/dev/null || true)"
  tooltip="Screen recording is active"
  if [ -n "$out" ]; then
    tooltip="${tooltip}\\n${out}"
  fi
  printf '{"text":" REC","class":"recording","tooltip":"%s"}\n' "$tooltip"
  exit 0
fi

if pgrep -x gpu-screen-rec >/dev/null 2>&1; then
  printf '{"text":" REC","class":"recording","tooltip":"Screen recording is active\\nClick to stop"}\n'
  exit 0
fi

printf '{"text":"","class":"idle","tooltip":""}\n'
exit 0
