#!/usr/bin/env bash
# Point the swaybar tray at the external monitor, with the name auto-detected.
#
# "External" = first active output whose name is not an internal panel
# (eDP-*/LVDS-*). Falls back to the first active output if none is found,
# so the tray is always rendered somewhere.
#
# Usage:
#   tray-output.sh            apply once
#   tray-output.sh --watch    apply now, then re-apply on every output hotplug
#
# autostart.sh starts the --watch mode; see that file.
set -euo pipefail

require() {
    command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }
}
require swaymsg
require jq

apply() {
    local target
    target="$(
        swaymsg -t get_outputs -r | jq -r '
            [ .[] | select(.active) ] as $active
            | ( [ $active[] | select(.name | test("^(eDP|LVDS)";"i") | not) ][0].name )
              // ( $active[0].name )
              // empty
        '
    )"

    [ -n "${target:-}" ] || { echo "No active output found." >&2; return 0; }

    # 'tray_output' appends to a list; 'none' first resets it so the result
    # is exactly one entry instead of accumulating stale outputs.
    swaymsg 'bar bar-0 tray_output none' >/dev/null
    swaymsg "bar bar-0 tray_output \"${target}\"" >/dev/null
}

apply

if [ "${1:-}" = "--watch" ]; then
    # Re-apply whenever an output is connected/disconnected/reconfigured.
    swaymsg -t subscribe -m '["output"]' | while read -r _; do
        apply
    done
fi
