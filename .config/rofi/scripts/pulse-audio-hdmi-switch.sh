#!/bin/bash

USER_NAME=$(who | grep tty$(sudo fgconsole) | cut -f1 -d' ')
USER_ID=$(id -u "$USER_NAME")
HDMI_STATUS=$(</sys/class/drm/card0/*HDMI*/status)

HDMI_CARD="pci-0000:00:1f.3"
HDMI_PROFILE="hdmi-stereo+input:analog-stereo"

INTERNAL_CARD="pci-0000_00_1b.0"
INTERNAL_PROFILE="analog-stereo"

export LANG=C
export PULSE_SERVER="unix:/run/user/$USER_ID/pulse/native"

function pactl_cmd() {
  sudo -u $USER_NAME pactl --server $PULSE_SERVER $*
}

if [ "$HDMI_STATUS" = "connected" ]; then
  CARD=$HDMI_CARD
  OUTPUT=$HDMI_PROFILE
else
  CARD=$INTERNAL_CARD
  OUTPUT=$INTERNAL_PROFILE
fi

pactl_cmd set-default-sink alsa_output.$CARD.$OUTPUT
pactl_cmd set-card-profile alsa_card.$CARD output:$OUTPUT

INPUTS=($(pactl_cmd list sink-inputs | grep "^Sink Input #"|cut -d# -f2))
for i in ${INPUTS[*]}; do
  pactl_cmd move-sink-input $i alsa_output.$CARD.$OUTPUT
done
