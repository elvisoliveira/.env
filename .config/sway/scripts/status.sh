#!/bin/sh
# swaybar status (texto puro, sem protocolo JSON). Reaproveita os scripts da
# barra do tmux (~/.env/.tmux.conf/bin) para ter uma única fonte dos segmentos.
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
