[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH="$PATH:$HOME/.local/bin/"

# tty1 login -> sway (Wayland-only session; the X11/i3 path is gone).
if [[ "$(tty)" = "/dev/tty1" ]]; then
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    # GTK theme comes from ~/.config/gtk-3.0/settings.ini (Chicago95); don't
    # force GTK_THEME here, it would override that.
    export XDG_DESKTOP_DIR="$HOME/downloads"
    export XDG_DOWNLOAD_DIR="$HOME/downloads"
    export XDG_CURRENT_DESKTOP=sway
    export XDG_SESSION_TYPE=wayland
    pgrep -x sway >/dev/null || exec sway
fi

[[ -f "$HOME/.deno/env" ]] && . "$HOME/.deno/env"
