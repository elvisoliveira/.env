#!/bin/sh
# swaybar status (plain text, no JSON protocol). Reuses the tmux status bar
# scripts (~/.env/.tmux.conf/bin) so the segments have a single source.
B="$HOME/.env/.tmux.conf/bin"
while :; do
    printf '%s%s | %s | BR %s | UK %s | NL %s \n' \
        "$("$B/status-seg" KB "$B/keyboard-layout" | cut -c4-)" \
        "$("$B/status-seg" BAT "$B/battery")" \
        "$(date '+%d/%m/%y')" \
        "$(TZ=America/Sao_Paulo date +%H:%M)" \
        "$(TZ=Europe/London date +%H:%M)" \
        "$(TZ=Europe/Amsterdam date +%H:%M)"
    sleep 5
done
