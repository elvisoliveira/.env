#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

## Get mouse positions and save directly to variables X/Y
eval $(xdotool getmouselocation --shell)

### get connected and active screen sizes/placements
### regex matches format e.g. 1920x1080+0+0
screens=$(xrandr | grep -Po '\d{0,5}x\d{0,5}\+\d{0,5}\+\d{0,5}')

for screen in $screens; do
    screen=($(echo $screen | awk -F '[x+]' '{print $1"\n"$2"\n"$3"\n"$4}'))

    screen_w="${screen[0]}"
    screen_h="${screen[1]}"
    screen_x="${screen[2]}"
    screen_y="${screen[3]}"

    if [ "$X" -ge "$screen_x" ] && [ "$X" -lt "$((screen_x + screen_w))" ] && [ "$Y" -ge "$screen_y" ] && [ "$Y" -lt "$((screen_y + screen_h))" ]; then
        /usr/bin/i3-msg "[con_mark=\"terminal\"] scratchpad show, resize set 100 ppt 100 ppt, move position $screen_x $screen_y"
        break
    fi
done
