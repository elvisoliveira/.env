#!/usr/bin/env bash
set -euo pipefail

selection="$(cliphist list | rofi -dmenu -i -p clipboard)"

if [ -z "${selection}" ]; then
  exit 0
fi

decoded="$(printf '%s\n' "${selection}" | cliphist decode)"

printf '%s' "${decoded}" | wl-copy
printf '%s' "${decoded}" | wl-copy --primary
