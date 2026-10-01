#!/usr/bin/env bash
set -euo pipefail

if ! command -v swaymsg >/dev/null 2>&1; then
  exit 0
fi

swaymsg input type:keyboard xkb_switch_layout next >/dev/null

tmux refresh-client -S

pkill -RTMIN+11 i3blocks 2>/dev/null || true
