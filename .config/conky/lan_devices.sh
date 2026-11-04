#!/usr/bin/env bash
# Devices on the home LAN for conky (prints the panel body). Call with execpi:
# it only prints the cache and, when that is older than MAX_AGE, starts a scan
# in the background, so conky never blocks on nmap.
#
# Scans only when the default gateway is the home router (its MAC is the
# "@home-gateway" line of lan_devices.map, which stays local), so
# other networks (work, hotels) are never swept. No root: an unprivileged
# `nmap -sn` still makes the kernel ARP every address, and the hosts that
# answered are read back from the neighbour table with their MAC; names come
# from lan_devices.map (keyed by mDNS hostname or MAC),
# else nmap's reverse DNS, else nmap's MAC prefix list.
#
# Usage: lan_devices.sh [count]   (rows shown; the rest is summed as "+N")
set -u

MAP="${BASH_SOURCE[0]%.sh}.map"
HOME_GW_MAC=$(awk '$1 == "@home-gateway" {print $2}' "$MAP" 2>/dev/null)
MAX_AGE=300
count="${1:-10}"
CACHE="${XDG_RUNTIME_DIR:-/tmp}/conky_lan"
VENDORS=/usr/share/nmap/nmap-mac-prefixes

scan() {
    read -r gw dev < <(ip -4 route show default | awk '{print $3, $5; exit}')
    mac=$(ip neigh show "$gw" dev "$dev" 2>/dev/null | awk '{print $3}')
    if [[ -z "$HOME_GW_MAC" || "$mac" != "$HOME_GW_MAC" ]]; then
        echo '| ${color grey}not on the home network${color}'
        return
    fi
    net=$(ip -4 -o addr show dev "$dev" scope global | awk '{print $4; exit}')
    # ponytail: refuse anything wider than a /24 instead of sweeping it
    [[ "${net#*/}" -ge 24 ]] || { echo "| \${color grey}$net too wide to scan\${color}"; return; }

    declare -A name
    while read -r ip host; do
        name[$ip]="$host"
    done < <(nmap -sn --max-retries 1 -oG - "$net" 2>/dev/null |
        awk '/Status: Up/ {h=$3; gsub(/[()]/, "", h); print $2, h}')

    declare -A alias
    while read -r host label; do
        [[ "$host" =~ ^#|^$ ]] || alias[$host]="$label"
    done < "$MAP"

    rows=()
    while read -r ip mac; do
        mdns=$(timeout 3 avahi-resolve -a "$ip" 2>/dev/null | awk '{sub(/\.local$/, "", $2); print $2}')
        label="${alias[$mac]:-${alias[${mdns:-_}]:-${name[$ip]:-}}}"
        if [[ -z "$label" ]]; then
            prefix=$(tr -d : <<<"${mac:0:8}" | tr a-f A-F)
            label=$(awk -v p="$prefix" '$1"" == p {$1 = ""; print substr($0, 2); exit}' "$VENDORS")
        fi
        rows+=("$(printf '| %-15s %s' "$ip" "${label:-$mac}")")
    done < <(ip -4 neigh show dev "$dev" | awk '$NF ~ /^(REACHABLE|DELAY|PROBE)$/ {print $1, $3}' | sort -t. -k4,4n)

    echo "| \${color grey}${#rows[@]} on $net · $(date +%H:%M)\${color}"
    for r in "${rows[@]:0:count}"; do echo "${r:0:40}"; done
    if (( ${#rows[@]} > count )); then echo "| \${color grey}+$(( ${#rows[@]} - count )) more\${color}"; fi
}

age=$(( $(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0) ))
if (( age > MAX_AGE )) && mkdir "$CACHE.lock" 2>/dev/null; then
    ( scan > "$CACHE.tmp" && mv "$CACHE.tmp" "$CACHE"; rmdir "$CACHE.lock" ) >/dev/null 2>&1 &
fi
[[ -s "$CACHE" ]] && cat "$CACHE" || echo '| ${color grey}scanning…${color}'
