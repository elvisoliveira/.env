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
# um Firechores já aberto vem para a tela em uso, centralizado (o arquivo vira uma aba nele)
out=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused).name')
swaymsg "[app_id=\"^firechores\$\"] move container to output $out, move position center" >/dev/null 2>&1
exec "$HOME/applications/Firechores.AppImage" "$file"
