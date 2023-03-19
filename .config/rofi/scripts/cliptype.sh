#!/bin/sh
xdotool type --delay 100 "$(rofi -dmenu -p 'Enter Text' -theme-str 'listview { enabled: false;}')"
