#!/usr/bin/env bash

refresh_i3blocks_keyboard() {
	pkill -RTMIN+11 i3blocks 2>/dev/null || true
}

(setxkbmap -query | grep -q "layout:\s\+us") && setxkbmap -model abnt2 -layout br -variant abnt2 || setxkbmap us
refresh_i3blocks_keyboard
exit

selected=$(echo "Portuguese
English
Dutch" | rofi -i -dmenu -config ~/.config/rofi/config.rasi -p "Keyboard layout" -f)

if [ "$selected" == "Portuguese" ]; then
	setxkbmap -model abnt2 -layout br -variant abnt2
fi

if [ "$selected" == "English" ]; then
	setxkbmap -layout us # -variant intl
fi

if [ "$selected" == "Dutch" ]; then
	setxkbmap -layout nl
fi

exit
