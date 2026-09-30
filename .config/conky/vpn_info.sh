#!/usr/bin/env bash
# VPN type / interface / IPv4 for conky (prints the two "VPN" panel lines).
# Type is guessed from the client process, interface from what is up.
set -u

all_ps="$(ps -eo args= 2>/dev/null)"

# First interface matching the glob whose operstate is "up", if any.
first_up() {
    local iface
    for iface in /sys/class/net/$1; do
        iface="${iface##*/}"
        [[ "$(cat "/sys/class/net/$iface/operstate" 2>/dev/null)" =~ ^(up|unknown)$ ]] && { echo "$iface"; return 0; }
    done
    return 1
}

detect() {
    local iface
    if iface="$(first_up 'wg*')"; then                                  echo "WireGuard|$iface"
    elif grep -Eqi 'openconnect .*(--protocol(=| )gp|globalprotect)' <<<"$all_ps"; then
                                                                        echo "GlobalProtect|$(first_up 'tun*' || echo tun0)"
    elif grep -Eqi 'openfortivpn|forticlientsslvpn|fortivpn' <<<"$all_ps"; then
                                                                        echo "Fortinet|$(first_up 'ppp*' || first_up 'tun*' || echo ppp0)"
    elif grep -qi 'openconnect' <<<"$all_ps"; then                       echo "OpenConnect|$(first_up 'tun*' || echo tun0)"
    elif iface="$(first_up 'tun*')" || iface="$(first_up 'ppp*')"; then  echo "VPN|$iface"
    else                                                                echo "Off|-"
    fi
}

vpn="$(detect)"
type="${vpn%%|*}"
iface="${vpn##*|}"

if [[ "$type" == Off ]]; then
    summary=Off ip4=-
else
    summary="$type / $iface"
    ip4="$(ip -o -4 addr show dev "$iface" 2>/dev/null | awk '{ sub("/.*", "", $4); print $4; exit }')"
fi
printf '| ${color grey}VPN:         ${color} %s\n' "$summary"
printf '| ${color grey}VPN IP:      ${color} %s\n' "${ip4:--}"
