#!/usr/bin/env bash
# Default audio output / input for conky. pactl's JSON already carries a human
# description and the state, so there is no sink-name surgery to do.
set -u

if ! pactl info >/dev/null 2>&1; then
    printf '| ${color grey}Status:${color} audio backend unavailable\n'
    exit 0
fi

# Short label from pactl's description; anything unknown is just truncated.
short_name() {
    local n
    case "$1" in
        *"Thunderbolt 4 Dock"*Mono)   echo "Thunderbolt Dock Mic" ;;
        *"Thunderbolt 4 Dock"*)       echo "Thunderbolt Dock" ;;
        *"HDMI / DisplayPort "[0-9]*) n="${1##*DisplayPort }"; echo "HDMI ${n%% *}" ;;
        *Headphones)                  echo "Built-in Headphones" ;;
        *"Stereo Microphone")         echo "Stereo Mic" ;;
        *"Digital Microphone")        echo "Digital Mic" ;;
        *)                            printf '%.20s\n' "$1" ;;
    esac
}

# line <label> <sinks|sources> <default device name>
line() {
    local label="$1" kind="$2" name="$3" state desc
    read -r state desc < <(pactl --format=json list "$kind" 2>/dev/null \
        | jq -r --arg n "$name" '.[] | select(.name == $n) | "\(.state) \(.description)"')
    if [[ -z "${desc:-}" ]]; then
        printf '| ${color grey}%-12s${color} no default\n' "$label"
        return
    fi
    [[ "$name" == bluez_input.* ]] && desc="$desc Mic"
    case "$state" in
        RUNNING) state=active ;; IDLE) state=idle ;; SUSPENDED) state=sleep ;; *) state="${state,,}" ;;
    esac
    printf '| ${color grey}%-12s${color} %s [%s]\n' "$label" "$(short_name "$desc")" "$state"
}

line 'Output:' sinks   "$(pactl get-default-sink 2>/dev/null)"
line 'Input:'  sources "$(pactl get-default-source 2>/dev/null)"
