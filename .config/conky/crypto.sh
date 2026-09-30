#!/usr/bin/env bash
# BTC / XMR spot price in USD for conky: one CoinGecko call for both coins.
set -u

json="$(curl -fsS --max-time 5 \
    'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,monero&vs_currencies=usd')" || json='{}'

# 65432 -> 65.432 (no pt_BR locale installed, so printf "%'d" can't do it)
group() { printf '%d' "$1" | rev | fold -w3 | paste -sd. - | rev; }

for coin in bitcoin:Bitcoin monero:Monero; do
    usd="$(jq -r ".${coin%%:*}.usd // empty" <<<"$json")"
    printf '| ${color grey}%s:${color} %s\n' "${coin#*:}" "$([[ -n $usd ]] && group "${usd%.*}" || echo N/A)"
done
