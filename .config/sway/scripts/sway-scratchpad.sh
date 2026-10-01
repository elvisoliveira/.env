#!/usr/bin/env bash
set -euo pipefail

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

if [ -z "${screen_w:-}" ] || [ -z "${screen_h:-}" ]; then
  exit 0
fi

swaymsg "[con_mark=\"scratchpad\"] scratchpad show, resize set ${screen_w} px ${screen_h} px, move absolute position ${screen_x} px ${screen_y} px" >/dev/null
