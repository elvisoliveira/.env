#!/usr/bin/env fish
# Lists floating windows from every workspace; the picked one is brought to
# the current workspace, focused and centered. The last window hidden with
# hide-window.fish (mark _last_hidden) comes first, so rofi preselects it.
set sel (swaymsg -t get_tree | jq -r '[
  .. | select(.type? == "workspace" and .name != "__i3_scratch") | .name as $ws  # scratchpad is its own use case
  | .floating_nodes[]
  | .id as $id | ([.. | select(.pid? != null)][0]) as $w   # floating_con may wrap the window
  | { last: any(.. ; (.marks? // []) | index("_last_hidden") != null),
      line: "\($id)\t[\($ws)] \($w.app_id // $w.window_properties.class // "?") — \($w.name)" }
  ] | sort_by(.last | not) | .[].line' \
  | rofi -dmenu -i -p floating); or exit 0
test -n "$sel"; or exit 0
set id (string split -m1 \t -- $sel)[1]

swaymsg "[con_id=$id] move container to workspace current, focus, move position center" >/dev/null
if swaymsg -t get_tree | jq -e --argjson id $id \
        '.. | select(.id? == $id) | any(.. ; (.marks? // []) | index("_last_hidden") != null)' >/dev/null
    swaymsg unmark _last_hidden >/dev/null
end
