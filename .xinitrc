# Read settings
SETTINGS_FILE="$HOME/.config/settings.json"
SCREENLAYOUT_DIR="$HOME/.screenlayout"

# Default to home if file doesn't exist or location is not set
if [ -f "$SETTINGS_FILE" ]; then
    LOCATION=$(jq -r '.location // "home"' "$SETTINGS_FILE")
else
    LOCATION="home"
fi

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
(sleep 10; conky -q -d -c ~/.config/conky/conky.conf) &

# for Stylus
# gromit-mpx &

# How to deactivate a dsplay
# xrandr --output eDP1 --off

# NVIDIA
# xrandr --setprovideroutputsource modesetting NVIDIA-0
# xrandr --auto

# DPI
# xrandr --dpi 80

# Execute the arandr profile script
profile_script="$SCREENLAYOUT_DIR/${LOCATION}.sh"
if [ -f "$profile_script" ]; then
    sh "$profile_script"
else
    echo "Warning: Monitor profile $profile_script not found, skipping xrandr configuration"
fi

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
