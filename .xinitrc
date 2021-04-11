#!/bin/sh

userresources=$HOME/.xresources
usermodmap=$HOME/.xmodmap

if [ -f "$userresources" ]; then
	xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
	xmodmap "$usermodmap"
fi

dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

clipmenud &

picom --config ~/.config/picom/picom.conf -b --experimental-backends --backend glx &

# How to deactivate a dsplay
# xrandr --output eDP1 --off

# xrandr --auto

# DPI
# xrandr --dpi 80

# Display
xrandr --output "eDP1" --auto --primary --scale 1x1
xrandr --output "HDMI1" --auto --mode 1920x1080 --right-of "eDP1" --scale 1x1
xrandr --output "DP1" --auto --mode 1440x900_75.00 --below "HDMI1" --scale 1x1

# WM
exec i3
