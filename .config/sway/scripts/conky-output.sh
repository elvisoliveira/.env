#!/bin/sh
# Manage which Wayland output conky renders on.
#
# conky's xinerama_head selects the output by index into sway's output list.
# It can't be switched at runtime, so changing the monitor means restarting
# both conky instances with a different CONKY_HEAD. The chosen head is saved
# so the choice survives a sway restart (autostart calls this with `start`).
#
# Usage: conky-output.sh [start|toggle]

STATE="${XDG_RUNTIME_DIR:-/tmp}/conky_head"
head=$(cat "$STATE" 2>/dev/null || echo 0)

if [ "$1" = "toggle" ]; then
    count=$(swaymsg -t get_outputs -r | jq 'length')
    [ "$count" -ge 1 ] 2>/dev/null || count=1
    head=$(( (head + 1) % count ))
    printf '%s\n' "$head" > "$STATE"
fi

# Do NOT move the swaybar from here: on sway 1.12, 'bar bar-N output' at runtime
# kills swaybar (get_layer_surface with a null wl_output) and sway does not
# respawn it. The bars' outputs are static in the sway config.
pkill -x conky 2>/dev/null

export CONKY_HEAD="$head"
conky -c "$HOME/.config/conky/conky-left.conf" &
conky -c "$HOME/.config/conky/conky-right.conf" &
