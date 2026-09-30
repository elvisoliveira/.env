#!/bin/sh

set -eu

selection="$(
	grep -h "^[^#]" "$HOME"/bookmarks/* \
		| rofi -dmenu -i -l 20 \
		| cut -d'#' -f1 \
		| xargs
)"

[ -n "${selection}" ] || exit 0

wtype "${selection}"
