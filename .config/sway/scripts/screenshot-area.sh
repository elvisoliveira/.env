#!/bin/sh

# Screenshot: slurp selects an area (spans all outputs, no picker)
# -> grim captures -> firechores opens it for annotation (as a new tab if it is already open).
# Quick Save (Export, in firechores) saves to the chosen folder + copies the absolute path.
# Closing the tab without saving discards it; Esc in slurp = cancel (nothing captured).
# /tmp: firechores only reads images from $HOME and /tmp.
# --delay N: select the area now and capture N s later (time to open a menu, hover something);
# the countdown shows in dunst.

dir=/tmp/firechores-shots
mkdir -p "$dir"

# --press / --hold: the same key bound on press and on release; holding it for
# at least hold_ms turns into --delay 3.
hold_ms=500
stamp="$XDG_RUNTIME_DIR/screenshot-press"
# sway repeats press bindings while the key is held, so keep the first stamp;
# one older than 10 s is stale (its release never fired) and gets replaced.
if [ "$1" = "--press" ]; then
    now=$(date +%s%N)
    old=$(cat "$stamp" 2>/dev/null || echo 0)
    [ $(( (now - old) / 1000000 )) -gt 10000 ] && echo "$now" > "$stamp"
    exit 0
fi
if [ "$1" = "--hold" ]; then
    held=$(( ($(date +%s%N) - $(cat "$stamp" 2>/dev/null || echo 0)) / 1000000 ))
    rm -f "$stamp"
    set --
    [ "$held" -ge "$hold_ms" ] && set -- --delay 3
fi

delay=0
[ "$1" = "--delay" ] && delay=${2:-3}

geom=$(slurp) || exit 0

i=$delay
while [ "$i" -gt 0 ]; do
    dunstify -r 9101 -t 1100 -u low "Screenshot" "Capturing in ${i}s…"
    sleep 1
    i=$((i - 1))
done
[ "$delay" -gt 0 ] && { dunstify -C 9101; sleep 0.2; } # the notification is gone before the capture

file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
# with a delay the pointer is included (that is what the wait is for: hovering something); without it, it
# would sit in the corner of the area just selected
cursor=""
[ "$delay" -gt 0 ] && cursor="-c"
grim $cursor -g "$geom" "$file" || exit 1
# an already open firechores moves to the focused output, centred (the file becomes a tab in it)
out=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused).name')
swaymsg "[app_id=\"^firechores\$\"] move container to output $out, move position center" >/dev/null 2>&1
exec "$HOME/applications/firechores.AppImage" "$file"
