#!/bin/sh

userresources=$HOME/.xresources
usermodmap=$HOME/.xmodmap

if [ -f "$userresources" ]; then
	xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
	xmodmap "$usermodmap"
fi

xrandr --output eDP1 --off

picom --config ~/.config/picom/picom.conf -b &
exec i3