#!/bin/sh
# Rewrites copied text so "$HOME/" becomes "~/". Run via: wl-paste --type text --watch
t=$(cat; echo .)   # "." keeps trailing newlines
t=${t%.}
case $t in
  *"$HOME"/*) printf %s "$t" | sed "s|$HOME/|~/|g" | wl-copy ;;
esac
