#!/bin/sh
xdotool type "$(grep -h "^[^#]" ~/bookmarks/* | rofi -dmenu -i -l 20 | cut -d'#' -f1)"
