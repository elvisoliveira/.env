[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH="$PATH:$HOME/.local/bin/"
export XAUTHORITY="$HOME/.xauthority"

if [[ "$(tty)" = "/dev/tty1" ]]; then
    pgrep i3 || startx
fi
