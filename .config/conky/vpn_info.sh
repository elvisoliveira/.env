#!/usr/bin/env bash

set -u

all_ps="$(ps -eo comm=,args= 2>/dev/null)"

is_up() {
    local iface="$1"
    [[ -r "/sys/class/net/$iface/operstate" ]] && [[ "$(cat "/sys/class/net/$iface/operstate" 2>/dev/null)" == "up" ]]
}

first_up_matching() {
    local pattern="$1"
    local iface

    for iface in /sys/class/net/*; do
        iface="${iface##*/}"
        [[ "$iface" == $pattern ]] || continue
        if is_up "$iface"; then
            printf '%s\n' "$iface"
            return 0
        fi
    done

    return 1
}

detect_type() {
    if iface="$(first_up_matching 'wg*')"; then
        printf 'WireGuard|%s\n' "$iface"
        return
    fi

    if grep -Eqi 'openconnect .*--protocol(=| )gp|openconnect .*globalprotect' <<<"$all_ps"; then
        iface="$(first_up_matching 'tun*')"
        printf 'GlobalProtect|%s\n' "${iface:-tun0}"
        return
    fi

    if grep -Eqi 'openfortivpn|forticlientsslvpn|fortivpn' <<<"$all_ps"; then
        iface="$(first_up_matching 'ppp*')"
        if [[ -z "${iface:-}" ]]; then
            iface="$(first_up_matching 'tun*')"
        fi
        printf 'Fortinet|%s\n' "${iface:-ppp0}"
        return
    fi

    if grep -Eqi 'openconnect' <<<"$all_ps"; then
        iface="$(first_up_matching 'tun*')"
        printf 'OpenConnect|%s\n' "${iface:-tun0}"
        return
    fi

    if iface="$(first_up_matching 'tun*')"; then
        printf 'VPN|%s\n' "$iface"
        return
    fi

    if iface="$(first_up_matching 'ppp*')"; then
        printf 'VPN|%s\n' "$iface"
        return
    fi

    printf 'Off|-\n'
}

get_ip() {
    local iface="$1"

    if [[ "$iface" == "-" ]]; then
        printf '-\n'
        return
    fi

    ip -o -4 addr show dev "$iface" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1
}

vpn="$(detect_type)"
vpn_type="${vpn%%|*}"
vpn_iface="${vpn##*|}"

case "${1:-summary}" in
    type)
        printf '%s\n' "$vpn_type"
        ;;
    iface)
        printf '%s\n' "$vpn_iface"
        ;;
    ip)
        get_ip "$vpn_iface"
        ;;
    summary)
        if [[ "$vpn_type" == "Off" ]]; then
            printf 'Off\n'
        else
            printf '%s / %s\n' "$vpn_type" "$vpn_iface"
        fi
        ;;
    *)
        printf 'N/A\n'
        ;;
esac
