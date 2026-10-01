#!/bin/sh
# Static image wallpaper via swaybg, per output.
#
# The video wallpaper is a separate, manual action:
#   mod+w        -> play-youtube-mpv.sh --wallpaper  (pick a YouTube link + quality)
#   mod+Shift+w  -> this script                      (kill the video, restore the image)
#
# This script just (re)sets the static image. It's used at startup, by
# mod+Shift+w, and by chbg. swaybg and mpvpaper can't share the background
# layer, so any running video wallpaper is stopped first.
#
# chbg writes one processed file per output ($BG-<output>). We build a single
# swaybg invocation with an -o/-i pair per output. Falls back to the legacy
# single $BG file (all outputs), then to a solid color.
set -u

BG="$HOME/.config/bg"

pkill -x mpvpaper 2>/dev/null    # stop any video wallpaper
pkill -x swaybg   2>/dev/null    # restart so new $BG-* (e.g. from chbg) show

set --
if command -v swaymsg >/dev/null 2>&1; then
    for out in $(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name'); do
        if [ -f "$BG-$out" ]; then
            set -- "$@" -o "$out" -m fill -i "$BG-$out"
        fi
    done
fi

if [ "$#" -gt 0 ]; then
    swaybg "$@" >/dev/null 2>&1 &
elif [ -f "$BG" ]; then
    swaybg -m fill -i "$BG" >/dev/null 2>&1 &
else
    swaybg -c '#67645B' >/dev/null 2>&1 &
fi
