[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH     = "$PATH:$(find "$HOME/.local/bin/" -type d | paste -sd)"
export EDITOR   = "vim"
export BROWSER  = "qutebrowser"
export TERMINAL = "alacritty"

if [[ "$(tty)" = "/dev/tty1" ]]; then
    pgrep i3 || startx
fi
