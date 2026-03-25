#!/usr/bin/env bash

process_name="${1:-}"

if [[ -z "$process_name" ]]; then
    printf '0.0\n'
    exit 0
fi

ps -C "$process_name" -o %cpu= | awk '
    { sum += $1 }
    END {
        if (NR) {
            printf "%.1f\n", sum
        } else {
            print "0.0"
        }
    }
'
