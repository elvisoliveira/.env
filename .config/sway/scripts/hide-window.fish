#!/usr/bin/env fish
# Hides the focused window by floating it past the right edge of every output
# (same as dragging it out of view). floating-menu.fish ($mod+g) brings it back.

set id (swaymsg -t get_tree | jq -r '.. | select(.focused? == true and .pid? != null) | .id' | head -1)
test -n "$id"; or exit 0
set ws (swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')

set edge (swaymsg -t get_outputs | jq '[.[] | select(.active) | .rect.x + .rect.width] | max')
# _last_hidden: sway marks are unique, so it always names the latest; $mod+g preselects it
swaymsg "[con_id=$id] mark --add _last_hidden, fullscreen disable, floating enable, move absolute position "(math $edge + 100)" px 0 px" >/dev/null

# Off-screen it belongs to the nearest output; return focus to where we were.
swaymsg workspace "$ws" >/dev/null
# Still focused (single output)? Don't leave keyboard focus on an invisible
# window: a tiled window, else a visible floating one, else the empty workspace.
set focused (swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .id')
test "$focused" = "$id"; or exit 0
swaymsg focus tiling >/dev/null 2>&1; and exit 0
set other (swaymsg -t get_tree | jq -r --argjson edge $edge --argjson id $id '
  .. | select(.type? == "workspace" and any(.. ; .id? == $id))
  | .floating_nodes[] | select(.id != $id and .rect.x < $edge) | .id' | head -1)
if test -n "$other"
    swaymsg "[con_id=$other] focus" >/dev/null
else
    swaymsg focus parent >/dev/null
end
