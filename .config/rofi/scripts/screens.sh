#!/bin/bash
# for output in eDP DP HDMI; do
#     export $output=$(xrandr | awk "/^$output/ && / connected/ {print \$1}")
# done
xrandr --output eDP1 --off --auto --scale 0.7 --primary \
       --output DP3-1-5 --auto --scale 1 --right-of eDP1 --mode 1920x1080
       #--output DP3-1-6 --off --auto --scale 1 --right-of eDP1 --mode 1920x1080 \
       # --output DP3-1-5 --auto --scale 1 --right-of DP3-1-6 --mode 1920x1080