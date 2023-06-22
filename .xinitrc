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
picom --config ~/.config/picom/picom.conf -b --backend glx &

# for Stylus
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

# xrandr --output eDP1 --auto --scale 0.7 --primary --output DP2 --auto --scale 1 --left-of eDP1
xrandr --output eDP1 --auto --scale 0.7 --primary --output DP2-1 --auto --scale 1 --right-of eDP1 --output DP2-2 --auto --scale 1 --right-of DP2-1
# xrandr --output eDP1 --auto --scale 0.7 --primary --output DP3-1 --auto --scale 1 --left-of DP3-2 --output DP3-2 --auto --scale 1 --above eDP1

# Display VR
# xrandr --output "HDMI1" --auto --scale 1x1 --mode 1024x768

export QT_QPA_PLATFORMTHEME=qt5ct
export QT_AUTO_SCREEN_SCALE_FACTOR=0

export GTK_THEME="Dracula"

export XDG_DESKTOP_DIR=$HOME/downloads
export XDG_DOWNLOAD_DIR=$HOME/downloads

export CM_LAUNCHER=rofi

# WM
exec i3
# nvidia-xrun i3
