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
    export GTK_A11Y=none NO_AT_BRIDGE=1
    # GIO without gvfs (gvfs-metadata is masked; apps warned about it). Thunar opts out (sway config and its
    # launcher in ~/.local/share/applications): it needs gvfs for Trash, removable drives and network places.
    export GIO_USE_VFS=local
    # firefox: no crashhelper process (crash reports are never sent anyway)
    export MOZ_CRASHREPORTER_DISABLE=1
    if ! pgrep -x sway >/dev/null; then
        # Monitor profile picked here, on the tty; sway's autostart.sh applies it via kanshictl.
        # Esc: kanshi picks one on its own.
        KANSHI_PROFILE=$(sed -n 's/^profile \([^ ]*\) {$/\1/p' ~/.config/kanshi/config |
            fzf --tac --height=~10 --reverse --prompt="Monitor profile > ")
        export KANSHI_PROFILE
        exec sway
    fi
fi

[[ -f "$HOME/.deno/env" ]] && . "$HOME/.deno/env"
