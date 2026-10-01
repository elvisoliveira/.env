#!/usr/bin/env bash
# Lock screen that mirrors the current desktop wallpaper:
#   - a video wallpaper (mpvpaper, started by mod+w) is running
#       -> animated lock: swaylock-plugin runs the SAME mpv options + URL
#          inside its own lock surface.
#   - otherwise
#       -> static image lock (swaylock -i <output>:$BG-<output>, per output).
#
# Why swaylock-plugin for the video case: stock swaylock uses ext-session-lock,
# which makes the compositor hide every other surface while locked, so a
# separate mpvpaper background layer can't show through. swaylock-plugin draws
# the plugin (mpvpaper) inside its own secure lock surface instead. If it isn't
# installed, this just falls back to the static lock.
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

# If a video wallpaper is live and swaylock-plugin is available, rebuild the
# running mpvpaper command (dropping the daemon -f flag) so the lock can play
# the exact same video. /proc/<pid>/cmdline is NUL-separated, so the quoted
# -o "..." options survive as a single field.
video_cmd=""
pid="$(pgrep -x mpvpaper | head -1 || true)"
if [ -n "$pid" ] && command -v swaylock-plugin >/dev/null 2>&1 && [ -r "/proc/$pid/cmdline" ]; then
    mapfile -d '' -t argv < "/proc/$pid/cmdline"
    rebuilt=(mpvpaper)
    for ((i = 1; i < ${#argv[@]}; i++)); do
        [ -z "${argv[i]}" ] && continue       # skip the trailing empty field
        [ "${argv[i]}" = "-f" ] && continue   # don't fork inside the lock
        rebuilt+=("${argv[i]}")
    done
    # %q so the whole command survives being passed as one --command string
    # (swaylock-plugin runs it through a shell).
    video_cmd="$(printf '%q ' "${rebuilt[@]}")"
fi

if [ -n "$video_cmd" ]; then
    exec swaylock-plugin -f "${theme[@]}" --command "$video_cmd"
else
    # chbg writes one processed image per output ($BG-<output>); mirror the
    # swaybg setup with swaylock's per-output -i <output>:<path>. Falls back to
    # the legacy single $BG file, else swaylock's solid default color.
    imgs=()
    for out in $(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name'); do
        [ -f "$BG-$out" ] && imgs+=(-i "$out:$BG-$out")
    done
    [ ${#imgs[@]} -eq 0 ] && [ -f "$BG" ] && imgs=(-i "$BG")
    exec swaylock -f "${imgs[@]}" "${theme[@]}"
fi
