#!/usr/bin/env bash
set -euo pipefail

slot="${1:-1}"

if ! command -v swaymsg >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

# Called from for_window: remember the size scrcpy asked for (= device aspect)
# before any resize, as a hidden mark.
if [ "$slot" = "mark" ]; then
  swaymsg -t get_tree -r | jq -r '
    .. | select(.window_properties?.class? == "scrcpy")
    | select(any(.marks[]; startswith("_scrcpy_ar_")) | not)
    | "\(.id) \(.geometry.width) \(.geometry.height)"' |
  while read -r id w h; do
    swaymsg "[con_id=${id}] mark --add _scrcpy_ar_${w}x${h}" >/dev/null
  done
  exit 0
fi

workspace_output=$(
  swaymsg -t get_workspaces -r |
    jq -r 'first(.[] | select(.focused) | .output) // empty'
)

if [ -z "${workspace_output}" ]; then
  exit 0
fi

read -r screen_x screen_y screen_w screen_h < <(
  swaymsg -t get_outputs -r |
    jq -r --arg output "$workspace_output" '
      first(
        .[]
        | select(.name == $output and .active)
        | [.rect.x, .rect.y, .rect.width, .rect.height]
        | @tsv
      ) // empty
    '
)

width=300  # same in both slots; height follows each device's aspect
peek=32  # px of the phone screen left visible when hidden (border added automatically); 32 = whole Pixel status bar

# Natural content size per window: the _scrcpy_ar_WxH mark recorded at map time,
# falling back to the current geometry for windows opened before the mark existed.
# The Pixel (scrcpy titles the window with the device model) always takes the
# rightmost slot and is the only one that keeps the peek when hidden; the rest
# hide completely below the screen.
i=0
swaymsg -t get_tree -r | jq -r '
  [.. | select(.window_properties?.class? == "scrcpy")]
  | sort_by(.name | test("^Pixel") | not)
  | .[]
  | ((.marks | map(select(startswith("_scrcpy_ar_"))) | first // "") | ltrimstr("_scrcpy_ar_") | split("x")) as $ar
  | [.id, ($ar[0] // .geometry.width), ($ar[1] // .geometry.height), .rect.width - .window_rect.width, .rect.height - .window_rect.height, .window_rect.y, (.name | test("^Pixel"))]
  | @tsv' |
while read -r id nat_w nat_h border_w border_h border_top is_pixel; do
  height=$(( (width - border_w) * nat_h / nat_w + border_h ))
  x=$((screen_x + screen_w - width * (i + 1)))
  if [ "$slot" = "1" ] && [ "$is_pixel" = "true" ]; then
    y=$((screen_y + screen_h - peek - border_top))
  elif [ "$slot" = "1" ]; then
    y=$((screen_y + screen_h))
  else
    y=$((screen_y + screen_h - height))
  fi
  swaymsg "[con_id=${id}] resize set ${width} px ${height} px, move absolute position ${x} ${y}" >/dev/null
  i=$((i + 1))
done
