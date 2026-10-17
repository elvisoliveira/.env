#!/usr/bin/env bash
# Save the current Sway output layout as a kanshi profile and reload kanshi.
#   save-output-profile.sh [name]    (no name: pick/type one in rofi)
# Outputs are written as "make model serial", so the profile keeps matching
# when a dock hands out a different DP-N name.
set -euo pipefail

config=~/.config/kanshi/config

name=${1:-$(sed -n 's/^profile \([^ ]*\) {$/\1/p' "$config" | rofi -dmenu -p "Save monitor profile")}
[ -n "$name" ] || exit 0

# Sway reports rotation clockwise, kanshi (wayland protocol) counter-clockwise,
# so 90 and 270 swap. The internal panel (eDP-*) is matched by name: it never
# moves port, and kanshi didn't match it by description.
block=$(swaymsg -t get_outputs -r | jq -r --arg name "$name" '
  def kanshi_transform: {"90": "270", "270": "90", "flipped-90": "flipped-270", "flipped-270": "flipped-90"}[.] // .;
  "profile \($name) {",
  (sort_by(.rect.x, .rect.y)[]
    | (if (.name | startswith("eDP")) then .name else "\"\(.make) \(.model) \(.serial)\"" end) as $id
    | "    output \($id) " + (
      if .active then
        "enable mode \(.current_mode.width)x\(.current_mode.height)@\(.current_mode.refresh / 1000)Hz"
        + " position \(.rect.x),\(.rect.y) scale \(.scale) transform \(.transform | kanshi_transform)"
      else "disable" end)),
  "}"')

# drop the old block with this name (and trailing blank lines), append the new one
awk -v name="$name" '
	$0 == "profile " name " {" { skip = 1; next }
	skip { if ($0 == "}") skip = 0; next }
	$0 == "" { blank++; next }
	{ while (blank) { print ""; blank-- } print }
' "$config" >"$config.tmp"
printf '\n%s\n' "$block" >>"$config.tmp"
mv "$config.tmp" "$config"

kanshictl reload
notify-send "Monitors" "Profile \"$name\" saved and applied"
