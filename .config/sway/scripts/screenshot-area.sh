#!/bin/sh

# Screenshot: slurp seleciona área (cruza todos monitores, sem picker)
# -> grim captura -> Firechores abre para anotar (vira uma aba se ele já estiver aberto).
# Quick Save (Export, no Firechores) salva na pasta escolhida + copia o path absoluto.
# Fechar a aba sem salvar descarta; Esc no slurp = cancela (nada capturado).
# /tmp: o Firechores só lê imagens de $HOME e /tmp.

dir=/tmp/firechores-shots
mkdir -p "$dir"

geom=$(slurp) || exit 0

file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
grim -g "$geom" "$file" || exit 1
exec "$HOME/applications/Firechores/firechores" "$file"
