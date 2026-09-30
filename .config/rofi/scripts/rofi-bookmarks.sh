#!/bin/sh

set -eu

selection="$(
	grep -h "^[^#]" "$HOME"/bookmarks/* \
		| rofi -dmenu -i -l 20 \
		| cut -d'#' -f1 \
		| xargs
)"

[ -n "${selection}" ] || exit 0

if [ "${XDG_SESSION_TYPE:-}" = "wayland" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
	wtype "${selection}"
else
	xdotool type "${selection}"
fi
