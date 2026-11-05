#!/usr/bin/env bash
set -euo pipefail

slot="${1:-1}"

if ! command -v swaymsg >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
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

x=$((screen_x + screen_w - 364))
y=$((screen_y + screen_h - 804))

if [ "$slot" = "1" ]; then
  y=$((y + 763))
fi

# One column per scrcpy window, right to left, so they never overlap.
i=0
for id in $(swaymsg -t get_tree -r | jq -r '.. | select(.window_properties?.class? == "scrcpy") | .id'); do
  swaymsg "[con_id=${id}] move absolute position $((x - i * 364)) ${y}" >/dev/null
  i=$((i + 1))
done
