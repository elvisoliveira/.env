#!/bin/sh
# Text watcher for cliphist: skips anything that looks like a password.
# Run via: wl-paste --type text --watch cliphist-store.sh
# Content marked sensitive by its app (CLIPBOARD_STATE=sensitive) is
# already dropped by cliphist itself; this catches unmarked ones.
# ponytail: naive heuristic — also skips tokens/hashes, lets weak passwords and
# passphrases with spaces through. Tune the rules in looks_like_password.

looks_like_password() {
    s=${1%"
"}                                   # ignore one trailing newline
    [ ${#s} -ge 12 ] && [ ${#s} -le 128 ] || return 1
    case $s in *[[:space:]]* | *://* | /* | '~/'* | ./* ) return 1 ;; esac  # spaces, URLs, paths
    # file:line[-line] references (nvim F1): a path with . or / ending in :N or :N-M
    printf %s "$s" | grep -Eq '^[^:]*[./][^:]*:[0-9]+(-[0-9]+)?$' && return 1
    n=0
    case $s in *[[:lower:]]*) n=$((n+1)) ;; esac
    case $s in *[[:upper:]]*) n=$((n+1)) ;; esac
    case $s in *[[:digit:]]*) n=$((n+1)) ;; esac
    case $s in *[![:alnum:]]*) n=$((n+1)) ;; esac
    [ $n -ge 3 ]
}

if [ "$1" = --test ]; then
    for p in 'Tr0ub4dor&3xyz' 'aB3dE6gH9jK2' 'x9#kL2$mQ7!z' 'aB3/dE6+gH9=jK2q'; do
        looks_like_password "$p" || { echo "FAIL (should skip): $p"; exit 1; }
    done
    for k in 'hello world 123' 'https://Example.com/a1' '/home/x/Projeto2025' '~/x/Proj2025' \
             'curto1A!' 'somentetextominusculo' 'git status --short' \
             'src/main.rs:10-25' '.config/sway/config:182-189' 'bin/float/tmux-float:97'; do
        looks_like_password "$k" && { echo "FAIL (should keep): $k"; exit 1; }
    done
    echo ok; exit 0
fi

t=$(cat; echo .)   # "." keeps trailing newlines
t=${t%.}
looks_like_password "$t" && exit 0
printf %s "$t" | cliphist store
