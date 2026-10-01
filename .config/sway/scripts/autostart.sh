#!/bin/sh

IDLE_TIMEOUT_MINUTES=5
IDLE_TIMEOUT_SECONDS=$((IDLE_TIMEOUT_MINUTES * 60))
WARN_SECONDS=$((IDLE_TIMEOUT_SECONDS - 10))

for proc in kanshi conky swayidle wl-paste; do
    pkill -x "$proc" 2>/dev/null
done
pkill -f 'sway/scripts/tray-output.sh --watch' 2>/dev/null

kanshi &

# tray-output.sh --watch foi desativado: a barra principal agora é fixa no
# eDP-1 (tray_output *), então apontar o tray para o monitor externo o
# deixaria invisível. O pkill acima segue limpando watchers antigos.

"$HOME/.config/sway/scripts/conky-output.sh" start &

swayidle -w \
    timeout "$WARN_SECONDS" 'dunstify -r 9001 -t 11000 -u normal "Tela" "Apagando em 10s por inatividade…"' \
    resume 'dunstify -C 9001' \
    timeout "$IDLE_TIMEOUT_SECONDS" 'swaymsg "output * power off"' \
    resume 'swaymsg "output * power on"' &

wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
