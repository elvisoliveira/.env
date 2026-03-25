#!/usr/bin/env bash

process_name="${1:-}"

if [[ -z "$process_name" ]]; then
    printf '0M\n'
    exit 0
fi

ps -C "$process_name" -o rss= | awk '
    { sum += $1 }
    END {
        if (!sum) {
            print "0M"
        } else if (sum >= 1024 * 1024) {
            printf "%.1fG\n", sum / (1024 * 1024)
        } else {
            printf "%.0fM\n", sum / 1024
        }
    }
'
