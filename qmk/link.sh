#!/bin/sh
# Symlink the tracked QMK keymaps into the (gitignored) QMK build tree, so
# `qmk compile/flash` reads them from here. Safe to re-run; updates each link.
set -eu

SRC="$HOME/.env/qmk/keyboards"
DST="$HOME/.env/qmk_keychron/keyboards"

if [ ! -d "$DST" ]; then
    echo "QMK tree not found at $DST — clone it there first." >&2
    exit 1
fi

find "$SRC" -type f | while IFS= read -r f; do
    rel="${f#"$SRC"/}"
    target="$DST/$rel"
    mkdir -p "$(dirname "$target")"
    ln -sfn "$f" "$target"
    echo "linked $rel"
done
