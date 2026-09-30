#!/usr/bin/env bash
# Top processes for conky, aggregated by the real binary (basename of
# /proc/<pid>/exe) so every instance of a program folds into one row, e.g. all
# node processes -> "node". Falls back to ps `comm` when exe is unreadable
# (other users, kernel threads). Output is conky markup; call with execpi.
#
# Usage: top_processes.sh <cpu|mem> [count]
#   CPU%  = summed ps %cpu / nproc   (100% = every core busy; ps %cpu is the
#           average since each process started, not instantaneous)
#   RAM   = absolute plus % of total physical memory, e.g. "4.5G (28%)"
set -euo pipefail

mode="${1:-mem}"
count="${2:-5}"
[[ "$mode" == cpu || "$mode" == mem ]] || {
    printf '| ${color #f38ba8}top_processes: invalid mode %s${color}\n' "$mode"; exit 1; }

# sort key in the aggregated rows "cpu memp rss name"
[[ "$mode" == cpu ]] && key=1 || key=3

# pass 1: "/proc/<pid> <exe target>" from one find; pass 2: ps rows.
awk '
    NR == FNR {                                   # pid -> basename(exe)
        i = index($0, " "); pid = substr($1, 7); t = substr($0, i + 1)
        sub(/ \(deleted\)$/, "", t); sub(/.*\//, "", t)
        if (t != "") exe[pid] = t
        next
    }
    { n = ($1 in exe) ? exe[$1] : $5; cpu[n] += $2; memp[n] += $3; rss[n] += $4 }
    END { for (n in cpu) print cpu[n], memp[n], rss[n], n }
' <(find /proc -maxdepth 2 -name exe -printf '%h %l\n' 2>/dev/null) \
  <(ps -eo pid=,%cpu=,%mem=,rss=,comm=) \
| sort -rn -k"$key" | head -n "$count" \
| awk -v mode="$mode" -v ncpu="$(nproc)" '{
    c = $1 / ncpu; mp = $2; r = $3; name = $4
    size = (r >= 1048576) ? sprintf("%.1fG", r / 1048576) : sprintf("%.0fM", r / 1024)
    if (mode == "cpu") { v = sprintf("%.1f%%", c);            hot = (c >= 50) }
    else               { v = sprintf("%s (%.0f%%)", size, mp); hot = (mp >= 25) }
    if (hot) v = "${color #f38ba8}" v "${color}"
    printf "| ${color grey}%s:${color} %s\n", name, v
}'
