#!/usr/bin/env bash

card="/sys/class/drm/card1"

name() {
    printf 'Iris Xe\n'
}

freq() {
    local cur max
    cur="$(cat "$card/gt_cur_freq_mhz" 2>/dev/null)"
    max="$(cat "$card/gt_max_freq_mhz" 2>/dev/null)"

    if [[ -n "$cur" && -n "$max" ]]; then
        printf '%s / %s MHz\n' "$cur" "$max"
    else
        printf 'N/A\n'
    fi
}

case "${1:-summary}" in
    name) name ;;
    freq|summary) freq ;;
    *)
        printf 'N/A\n'
        ;;
esac
