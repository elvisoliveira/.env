#!/usr/bin/env bash
# Lock screen that mirrors the current static wallpaper
# (swaylock -i <output>:$BG-<output>, per output).
set -u

BG="$HOME/.config/bg"

# Dracula palette + fill scaling. The laptop panel (eDP-1) is 16:10 while the
# wallpaper is 16:9 — swaylock's default "fit" would letterbox it; "fill" covers
# every output. Colors match the sway client.* theme (#8BE9FD / #FF5555 / ...).
theme=(
    --scaling=fill
    --indicator-radius 110 --indicator-thickness 8
    --ring-color 282A36       --inside-color 282A36cc       --text-color F8F8F2
    --ring-ver-color 8BE9FD   --inside-ver-color 282A36cc   --text-ver-color 8BE9FD
    --ring-wrong-color FF5555 --inside-wrong-color 282A36cc --text-wrong-color FF5555
    --ring-clear-color 50FA7B --inside-clear-color 282A36cc --text-clear-color 50FA7B
    --key-hl-color 8BE9FD --bs-hl-color FF5555
    --line-color 00000000 --separator-color 00000000
)

# chbg writes one processed image per output ($BG-<output>); mirror the
# swaybg setup with swaylock's per-output -i <output>:<path>. Falls back to
# the legacy single $BG file, else swaylock's solid default color.
imgs=()
for out in $(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name'); do
    [ -f "$BG-$out" ] && imgs+=(-i "$out:$BG-$out")
done
[ ${#imgs[@]} -eq 0 ] && [ -f "$BG" ] && imgs=(-i "$BG")
exec swaylock -f "${imgs[@]}" "${theme[@]}"
