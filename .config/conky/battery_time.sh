#!/usr/bin/env bash

base="/sys/class/power_supply/BAT0"
status="$(cat "$base/status" 2>/dev/null)"
energy_now="$(cat "$base/energy_now" 2>/dev/null)"
energy_full="$(cat "$base/energy_full" 2>/dev/null)"
power_now="$(cat "$base/power_now" 2>/dev/null)"

format_minutes() {
    local minutes="$1"
    local hours mins

    if [[ -z "$minutes" || "$minutes" -le 0 ]]; then
        printf '%s' --
        return
    fi

    hours=$((minutes / 60))
    mins=$((minutes % 60))

    if ((hours > 0)); then
        printf '%dh%02dm' "$hours" "$mins"
    else
        printf '%dm' "$mins"
    fi
}

if [[ -z "$status" ]]; then
    printf 'N/A\n'
    exit 0
fi

if [[ "$status" == "Full" ]]; then
    printf 'Full\n'
    exit 0
fi

if [[ -z "$power_now" || "$power_now" == "0" ]]; then
    if [[ "$status" == "Charging" ]]; then
        printf 'AC\n'
    else
        printf '%s\n' --
    fi
    exit 0
fi

case "$status" in
    Charging)
        minutes=$(awk -v now="$energy_now" -v full="$energy_full" -v power="$power_now" 'BEGIN {
            if (power <= 0 || full <= now) { print 0; exit }
            printf "%d\n", ((full - now) / power) * 60
        }')
        printf '+%s\n' "$(format_minutes "$minutes")"
        ;;
    Discharging)
        minutes=$(awk -v now="$energy_now" -v power="$power_now" 'BEGIN {
            if (power <= 0 || now <= 0) { print 0; exit }
            printf "%d\n", (now / power) * 60
        }')
        format_minutes "$minutes"
        printf '\n'
        ;;
    *)
        printf '%s\n' "$status"
        ;;
esac
