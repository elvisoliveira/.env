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

xrandr --output eDP1 --off

picom --config ~/.config/picom/picom.conf -b --experimental-backends --backend glx &
exec i3
