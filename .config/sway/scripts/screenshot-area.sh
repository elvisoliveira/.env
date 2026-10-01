#!/bin/sh

# Screenshot: slurp seleciona área (cruza todos monitores, sem picker)
# -> grim captura -> satty anota.
# Enter: salva ~/Pictures/Screenshots/<data>.png + copia path absoluto + sai.
# Esc no slurp = cancela (nada capturado).

dir="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$dir"

geom=$(slurp) || exit 0

grim -g "$geom" - | satty -f - \
    --output-filename "$dir/%Y-%m-%d_%H-%M-%S.png" \
    --actions-on-enter save-to-file,copy-filepath-to-clipboard,exit \
    --copy-command wl-copy
