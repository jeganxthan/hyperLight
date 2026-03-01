#!/usr/bin/env bash
# ╔═══════════════════════════════════════════════════════════╗
# ║  phonebridge-reply.sh                                    ║
# ║  Called by SwayNC notification action button.            ║
# ║  Opens a rofi/wofi prompt and writes reply to            ║
# ║  /tmp/phonebridge_reply for the Rust daemon to pick up.  ║
# ╚═══════════════════════════════════════════════════════════╝
#
# Usage (called automatically by SwayNC scripts config):
#   phonebridge-reply.sh <app> <sender> [thread_id]
#
# Deploy: cp phonebridge-reply.sh ~/.config/phonebridge/
#         chmod +x ~/.config/phonebridge/phonebridge-reply.sh

APP="${1:-sms}"
SENDER="${2:-}"
THREAD_ID="${3:-0}"
SENDER_DISPLAY="${SENDER}"

if [[ -z "$SENDER" ]]; then
    echo "Usage: $0 <app> <sender> [thread_id]" >&2
    exit 1
fi

REPLY_FILE="/tmp/phonebridge_reply"

# ── Choose prompt tool (rofi preferred, fallback to wofi, then zenity) ──
prompt_reply() {
    local placeholder="Reply to ${SENDER_DISPLAY}..."

    if command -v rofi &>/dev/null; then
        rofi \
            -dmenu \
            -p "󰤿 Reply to ${SENDER_DISPLAY}" \
            -theme-str '
                window {
                    width: 480px;
                    location: north east;
                    anchor: north east;
                    x-offset: -12px;
                    y-offset: 48px;
                    background-color: rgba(4,4,10,0.96);
                    border: 1px solid rgba(110,122,228,0.30);
                    border-radius: 12px;
                }
                mainbox {
                    padding: 12px 14px;
                    background-color: transparent;
                }
                inputbar {
                    background-color: rgba(255,255,255,0.04);
                    border: 1px solid rgba(255,255,255,0.10);
                    border-radius: 8px;
                    padding: 8px 12px;
                    children: [entry];
                }
                entry {
                    font: "JetBrainsMono Nerd Font 12";
                    color: rgba(220,222,238,0.95);
                    placeholder: "'"$placeholder"'";
                    placeholder-color: rgba(90,92,120,0.55);
                }
                prompt {
                    font: "JetBrainsMono Nerd Font 11";
                    color: rgba(110,122,228,0.85);
                    padding: 0 8px 0 0;
                }
                listview { lines: 0; }
            ' \
            -no-fixed-num-lines \
            -no-show-icons \
            < /dev/null

    elif command -v wofi &>/dev/null; then
        wofi \
            --dmenu \
            --prompt "Reply to ${SENDER_DISPLAY}" \
            --width 460 \
            --height 52 \
            --style <(cat <<'WOFI_CSS'
window {
    background-color: rgba(4,4,10,0.95);
    border: 1px solid rgba(110,122,228,0.28);
    border-radius: 12px;
}
#input {
    background-color: rgba(255,255,255,0.04);
    color: rgba(220,222,238,0.95);
    border: none;
    border-radius: 8px;
    padding: 8px 12px;
    font-family: "JetBrainsMono Nerd Font";
    font-size: 12px;
}
WOFI_CSS
            )

    elif command -v zenity &>/dev/null; then
        zenity \
            --entry \
            --title="PhoneBridge Reply" \
            --text="Reply to ${SENDER_DISPLAY}:" \
            --width=400

    else
        notify-send -a PhoneBridge "Reply Error" "Install rofi or wofi to use inline reply" -u critical
        exit 1
    fi
}

# ── Get reply text ────────────────────────────────────────────
REPLY_TEXT="$(prompt_reply)"

# Empty or cancelled
if [[ -z "$REPLY_TEXT" ]]; then
    exit 0
fi

# ── Write reply command for Rust daemon ──────────────────────
printf '%s' "{\"app\":\"${APP}\",\"sender\":\"${SENDER}\",\"thread_id\":${THREAD_ID},\"text\":$(printf '%s' "$REPLY_TEXT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}" \
    > "$REPLY_FILE"

# ── Confirmation toast ────────────────────────────────────────
/usr/bin/notify-send \
    --app-name "PhoneBridge" \
    --urgency low \
    --expire-time 2500 \
    "󰤿 Sent to ${SENDER_DISPLAY}" \
    "${REPLY_TEXT:0:60}$([ ${#REPLY_TEXT} -gt 60 ] && echo '...' || true)"