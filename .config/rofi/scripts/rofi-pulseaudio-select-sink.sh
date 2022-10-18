#!/usr/bin/env bash
# pacmd list-cards | grep HDMI
# pactl set-card-profile 0 output:hdmi-stereo

sink=$(pacmd list-sinks | grep -e 'name:' -e 'index:' |
    # merge every other line into previous
    paste -d" " - - |
    # make the strings much more read- and understandable
    sed 's/name: <\(.*\)>/\1/g' | sed 's/index: //g' |
    # user selection using rofi
    rofi -i -dmenu -config ~/.config/rofi/config.rasi -p "Audio devices" -f)

[[ $sink ]] || exit 0

sink_index=$(echo $sink | cut -d " " -f 1)

[[ $sink_index =~ ^[0-9]+$ ]] || exit 0

pactl set-default-sink $sink_index
pactl list short sink-inputs | cut -c1-1 - | xargs -I % pactl move-sink-input % $sink_index
