#!/usr/bin/env bash

set -u

ICON_BT='󰂯'

# Nerd Font icon for the device, based on bluez Icon hint.
type_icon() {
    case "$1" in
        audio-*)        printf '󰋋' ;; # headphones
        input-mouse)    printf '󰍽' ;; # mouse
        input-keyboard) printf '󰌌' ;; # keyboard
        phone)          printf '󰄱' ;; # phone
        *)              printf '󰂯' ;; # bluetooth
    esac
}

# Nerd Font battery ramp glyph for a 0-100 level.
battery_icon() {
    local lvl="$1"
    case $(( (lvl + 5) / 10 )) in
        0)  printf '󰂎' ;; # empty
        1)  printf '󰁺' ;; # 10
        2)  printf '󰁻' ;; # 20
        3)  printf '󰁼' ;; # 30
        4)  printf '󰁽' ;; # 40
        5)  printf '󰁾' ;; # 50
        6)  printf '󰁿' ;; # 60
        7)  printf '󰂀' ;; # 70
        8)  printf '󰂁' ;; # 80
        9)  printf '󰂂' ;; # 90
        *)  printf '󰁹' ;; # 100
    esac
}

# MAC (underscored) of the device currently routing audio, or empty.
default_sink_mac() {
    local s
    s="$(pactl get-default-sink 2>/dev/null)"
    case "$s" in
        bluez_output.*) s="${s#bluez_output.}"; printf '%s' "${s%%.*}" ;;
    esac
}

# Active audio codec for a device. Prints "<low>\t<label>" (low=1 means a
# degraded HSP/HFP call profile). Returns non-zero when the device has no
# active audio profile (e.g. mouse/keyboard).
audio_status() {
    local desc codec
    desc="$(pactl --format=json list cards 2>/dev/null | jq -r --arg c "bluez_card.${1//:/_}" \
        '.[] | select(.name == $c and .active_profile != "off") | .profiles[.active_profile].description // empty')"

    [[ -z "$desc" ]] && return 1

    codec="$(printf '%s' "$desc" | sed -n 's/.*codec \([A-Za-z0-9-]*\).*/\1/p')"
    if printf '%s' "$desc" | grep -q 'HSP/HFP'; then
        printf '1\t󰍬 HFP·%s' "$codec"   # mic in use → low-quality call profile
    else
        printf '0\t󰓃 %s' "$codec"
    fi
}

print_header() {
    printf '| %s Bluetooth Devices%s\n' "$ICON_BT" "${1:-}"
    printf '+---------------------------------------+\n'
}

if ! command -v bluetoothctl >/dev/null 2>&1; then
    print_header
    printf '| ${color grey}Status:${color} bluetoothctl unavailable\n'
    exit 0
fi

show_output="$(bluetoothctl show 2>/dev/null)"

if [[ -z "$show_output" ]]; then
    print_header
    printf '| ${color grey}Status:${color} bluetooth unavailable\n'
    exit 0
fi

powered="$(printf '%s\n' "$show_output" | sed -n 's/^[[:space:]]*Powered: //p' | head -n1)"

if [[ "$powered" != "yes" ]]; then
    print_header
    printf '| ${color grey}Controller:${color} off\n'
    exit 0
fi

connected="$(bluetoothctl devices Connected 2>/dev/null)"
count="$(printf '%s\n' "$connected" | grep -c '^Device ')"

print_header " ($count)"
printf '| ${color grey}Controller:${color} on\n'

if [[ "$count" -eq 0 ]]; then
    printf '| ${color grey}Connected:${color} none\n'
    exit 0
fi

default_mac="$(default_sink_mac)"

while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    mac="${line#Device }"
    mac="${mac%% *}"
    name="${line#Device ??\:??\:??\:??\:??\:?? }"
    (( ${#name} > 30 )) && name="${name:0:27}..."

    info="$(bluetoothctl info "$mac" 2>/dev/null)"
    icon_hint="$(printf '%s\n' "$info" | sed -n 's/^[[:space:]]*Icon: //p' | head -n1)"

    # Name line, starred when this device is the active audio output.
    star=""
    if [[ -n "$default_mac" && "${mac//:/_}" == "$default_mac" ]]; then
        star=' ${color #a6e3a1}★${color}'
    fi
    printf '| %s %s%s\n' "$(type_icon "$icon_hint")" "$name" "$star"

    # Battery Percentage line looks like: "Battery Percentage: 0x32 (50)"
    battery="$(printf '%s\n' "$info" \
        | sed -n 's/.*Battery Percentage:.*(\([0-9]\+\)).*/\1/p' | head -n1)"

    # Codec fragment for audio devices.
    codec_frag=""
    if [[ "$icon_hint" == audio-* ]] && cs="$(audio_status "$mac")"; then
        low="${cs%%$'\t'*}"
        label="${cs#*$'\t'}"
        if [[ "$low" == 1 ]]; then
            printf -v codec_frag ' ${color #f38ba8}· %s${color}' "$label"
        else
            printf -v codec_frag ' ${color grey}· %s${color}' "$label"
        fi
    fi

    # Second, indented line: battery and/or codec.
    if [[ -n "$battery" ]]; then
        if (( battery < 20 )); then
            printf '|   ${color #f38ba8}%s %s%%${color}%s\n' \
                "$(battery_icon "$battery")" "$battery" "$codec_frag"
        else
            printf '|   ${color grey}%s${color} %s%%%s\n' \
                "$(battery_icon "$battery")" "$battery" "$codec_frag"
        fi
    elif [[ -n "$codec_frag" ]]; then
        printf '|  %s\n' "$codec_frag"
    fi
done <<< "$connected"
