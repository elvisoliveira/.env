[[ -f ~/.bashrc ]] && . ~/.bashrc

export PATH="$PATH:$HOME/.local/bin/"

if [[ "$(tty)" = "/dev/tty1" ]]; then
    select-location
    SELECTED_WM="$(select-wm)"

    case "$SELECTED_WM" in
        sway)
            export QT_AUTO_SCREEN_SCALE_FACTOR=0
            # GTK theme is controlled by gsettings/~/.config/gtk-3.0/settings.ini
            # (Chicago95). Don't force it here — GTK_THEME would override those.
            # export GTK_THEME=Dracula
            export XDG_DESKTOP_DIR="$HOME/downloads"
            export XDG_DOWNLOAD_DIR="$HOME/downloads"
            export CM_LAUNCHER=rofi
            export XDG_CURRENT_DESKTOP=sway
            export XDG_SESSION_TYPE=wayland
            pgrep -x sway >/dev/null || exec sway
            ;;
        *)
            # i3/X11 removido (migrado para Wayland/sway) — fallback para sway.
            pgrep -x sway >/dev/null || exec sway
            ;;
    esac
fi

. "/home/elvisoliveira/.deno/env"
