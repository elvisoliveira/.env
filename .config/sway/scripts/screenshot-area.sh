#!/bin/sh

# Screenshot: slurp seleciona área (cruza todos monitores, sem picker)
# -> grim captura -> Firechores abre para anotar (vira uma aba se ele já estiver aberto).
# Quick Save (Export, no Firechores) salva na pasta escolhida + copia o path absoluto.
# Fechar a aba sem salvar descarta; Esc no slurp = cancela (nada capturado).
# /tmp: o Firechores só lê imagens de $HOME e /tmp.
# --delay N: seleciona a área agora e captura N s depois (dá tempo de abrir um menu, passar o mouse em algo);
# a contagem aparece no dunst.

dir=/tmp/firechores-shots
mkdir -p "$dir"

# --press / --hold: the same key bound on press and on release; holding it for
# at least hold_ms turns into --delay 3.
hold_ms=500
stamp="$XDG_RUNTIME_DIR/screenshot-press"
# sway repeats press bindings while the key is held, so keep the first stamp;
# one older than 10 s is stale (its release never fired) and gets replaced.
if [ "$1" = "--press" ]; then
    now=$(date +%s%N)
    old=$(cat "$stamp" 2>/dev/null || echo 0)
    [ $(( (now - old) / 1000000 )) -gt 10000 ] && echo "$now" > "$stamp"
    exit 0
fi
if [ "$1" = "--hold" ]; then
    held=$(( ($(date +%s%N) - $(cat "$stamp" 2>/dev/null || echo 0)) / 1000000 ))
    rm -f "$stamp"
    set --
    [ "$held" -ge "$hold_ms" ] && set -- --delay 3
fi

delay=0
[ "$1" = "--delay" ] && delay=${2:-3}

geom=$(slurp) || exit 0

i=$delay
while [ "$i" -gt 0 ]; do
    dunstify -r 9101 -t 1100 -u low "Screenshot" "Capturando em ${i}s…"
    sleep 1
    i=$((i - 1))
done
[ "$delay" -gt 0 ] && { dunstify -C 9101; sleep 0.2; } # a notificação some antes da captura

file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
# com atraso, o ponteiro entra na imagem (é para isso que se espera: o mouse sobre algo); sem, ele estaria
# no canto da área recém-selecionada
cursor=""
[ "$delay" -gt 0 ] && cursor="-c"
grim $cursor -g "$geom" "$file" || exit 1
# um Firechores já aberto vem para a tela em uso, centralizado (o arquivo vira uma aba nele)
out=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused).name')
swaymsg "[app_id=\"^firechores\$\"] move container to output $out, move position center" >/dev/null 2>&1
exec "$HOME/applications/Firechores.AppImage" "$file"
