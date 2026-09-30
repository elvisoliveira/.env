#!/bin/bash
# Type free text into the focused window (Wayland/sway). wtype works on native
# Wayland clients; xdotool only reached XWayland windows.
text=$(rofi -dmenu -p 'Enter Text' -theme-str 'listview { enabled: false; }')
[ -n "$text" ] && wtype -- "$text"
