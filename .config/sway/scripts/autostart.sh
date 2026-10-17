#!/bin/sh

IDLE_TIMEOUT_MINUTES=5
IDLE_TIMEOUT_SECONDS=$((IDLE_TIMEOUT_MINUTES * 60))
WARN_SECONDS=$((IDLE_TIMEOUT_SECONDS - 10))

# exec_always also runs on reload: only apply the tty-picked profile on session start
pgrep -x kanshi >/dev/null && session_start= || session_start=1

for proc in kanshi conky swayidle wl-paste; do
    pkill -x "$proc" 2>/dev/null
done

kanshi &

# KANSHI_PROFILE is picked on the tty by ~/.bash_profile; empty keeps kanshi's own pick
if [ -n "$session_start" ] && [ -n "$KANSHI_PROFILE" ]; then
    (
        # kanshi's socket may not be up yet; give it a few tries
        for _ in 1 2 3 4 5 6 7 8 9 10; do
            kanshictl switch "$KANSHI_PROFILE" 2>/dev/null && exit 0
            sleep 0.3
        done
        notify-send "Monitors" "Could not apply profile \"$KANSHI_PROFILE\""
    ) &
fi

"$HOME/.config/sway/scripts/conky-output.sh" start &

swayidle -w \
    timeout "$WARN_SECONDS" 'dunstify -r 9001 -t 11000 -u normal "Screen" "Turning off in 10s due to inactivity…"' \
    resume 'dunstify -C 9001' \
    timeout "$IDLE_TIMEOUT_SECONDS" 'swaymsg "output * power off"' \
    resume 'swaymsg "output * power on"' &

wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
