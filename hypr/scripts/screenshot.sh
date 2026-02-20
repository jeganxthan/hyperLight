#!/bin/bash

FILE="$HOME/Pictures/screenshot_$(date +%F_%T).png"

grim "$FILE"
paplay ~/.config/hypr/sounds/shutter.wav
notify-send "📸 Screenshot Saved"
