#!/bin/sh
# Static image wallpaper via swaybg, per output.
# Used at startup, by mod+Shift+w, and by chbg.
#
# chbg writes one processed file per output ($BG-<output>). We build a single
# swaybg invocation with an -o/-i pair per output. Falls back to the legacy
# single $BG file (all outputs), then to a solid color.
set -u

BG="$HOME/.config/bg"

pkill -x swaybg   2>/dev/null    # restart so new $BG-* (e.g. from chbg) show

set --
for out in $(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name'); do
    if [ -f "$BG-$out" ]; then
        set -- "$@" -o "$out" -m fill -i "$BG-$out"
    fi
done

# Launched through sway so swaybg is sway's child, not ours: when chbg.service
# calls this script, swaybg would otherwise stay in the service's cgroup.
if [ "$#" -gt 0 ]; then
    swaymsg -- exec swaybg "$@" >/dev/null
elif [ -f "$BG" ]; then
    swaymsg -- exec swaybg -m fill -i "$BG" >/dev/null
else
    swaymsg -- exec swaybg -c "'#67645B'" >/dev/null
fi
