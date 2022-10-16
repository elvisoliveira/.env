#!/bin/sh
userresources=$HOME/.Xresources
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
# gromit-mpx &

# How to deactivate a dsplay
# xrandr --output eDP1 --off

# NVIDIA
# xrandr --setprovideroutputsource modesetting NVIDIA-0
# xrandr --auto

# DPI
# xrandr --dpi 80

# Display Screens
for output in eDP DP HDMI; do
    REGEX="/^$output/{print "
    REGEX+='$1}'
    export $output=$(xrandr | awk "$REGEX")
done

xrandr --output $eDP --auto --scale 1x1 --primary
# xrandr --newmode "1920x1080_60.00"  172.80  1920 2040 2248 2576  1080 1081 1084 1118  -HSync +Vsync
# xrandr --addmode $DP "1920x1080_60.00"
# xrandr --output $DP --auto --scale 1x1 --mode "1920x1080_60.00" --right-of $eDP --rotate left
xrandr --output $HDMI --auto --scale 1x1 --mode 1920x1080 --left-of $eDP

# Display VR
# xrandr --output "HDMI1" --auto --scale 1x1 --mode 1024x768

# WM
exec i3
# nvidia-xrun i3
