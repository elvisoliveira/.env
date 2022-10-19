[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH="$PATH:$HOME/.local/bin/"

if [[ "$(tty)" = "/dev/tty1" ]]; then
    pgrep i3 || startx
fi
