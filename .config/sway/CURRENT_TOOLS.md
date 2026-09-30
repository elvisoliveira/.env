# Current Tools vs Wayland/Sway

Detected from your current environment (`command -v`) on 2026-03-26.

| Tool | Installed | Wayland Compatibility | Action | Suggested Alternative / Notes |
|---|---|---|---|---|
| `i3` | Yes | No (X11 WM) | Replace for Wayland sessions | `sway` |
| `i3blocks` | Yes | Yes | Keep | Works in `swaybar` |
| `rofi` | Yes | Partial (X11 build) | Replace | `rofi-wayland` |
| `clipmenu` | Yes | Limited (X11 clipboard) | Replace | `cliphist` + `wl-clipboard` |
| `xdotool` | Yes | No native Wayland control | Replace | `wtype` (typing), Sway IPC (`swaymsg`) for window control |
| `xrandr` | Yes | No (X11 output API) | Replace | `kanshi` / `swaymsg output ...` |
| `xbacklight` | Yes | Usually no under Wayland | Replace | `brightnessctl` |
| `satty` | Yes | Yes | Keep | Annotator; `slurp`+`grim` feed it. Replaced flameshot (picker bug no wayland) e swappy |
| `setxkbmap` | Yes | No (X11 keyboard API) | Replace | Sway `input` config + `swaymsg input ... xkb_switch_layout ...` |
| `picom` | Yes | Not needed | Remove from Sway startup | Sway has built-in compositor |
| `xmodmap` | Yes | No (X11 keymap tweaks) | Replace | Sway `input` options / XKB config |
| `xwallpaper` | Yes | No (X11 wallpaper) | Replace | `swaybg` |
| `conky` | Yes | Works, but often X11-oriented | Optional keep/replace | Keep if it works for you, or move status into `i3blocks`/`waybar` |
| `jq` | Yes | Yes | Keep | Used by Sway helper scripts |
| `curl` | Yes | Yes | Keep | Used by crypto block |
| `acpi` | Yes | Yes | Keep | Battery script |
| `sensors` | Yes | Yes | Keep | Temperature script (`lm_sensors`) |
| `ip` | Yes | Yes | Keep | Network script (`iproute2`) |
| `playerctl` | Yes | Yes | Keep | Media keybinds |
| `pcmanfm-qt` | Yes | Yes | Keep | File manager |
| `wezterm` | Yes | Yes | Keep | Terminal (`$term`, native tabs) |
| `tabbed` | Yes | Mostly X11-centric | Optional replace | Replaced by wezterm native tabs |
| `scrcpy` | Yes | Yes | Keep | Works; script logic moved to `swaymsg` |
| `pactl` | Yes | Yes | Keep | Audio sink switching |
| `dbus-update-activation-environment` | Yes | Yes | Keep | Session env sync |
| `ytfzf` | No | Yes | Optional install | `ytfzf` (AUR in many setups) |
| `pacmd` | No | Legacy PulseAudio tool | Optional install or avoid | Prefer `pactl`; only install if your script still requires `pacmd` |
| `sway` | No | Yes | Install | `sway` |
| `swaybg` | No | Yes | Install | `swaybg` |
| `swaylock` | No | Yes | Install | `swaylock` |
| `swayidle` | No | Yes | Install | `swayidle` |
| `swaymsg` | No | Yes | Install | Included with `sway` |
| `grim` | No | Yes | Install | `grim` |
| `slurp` | No | Yes | Install | `slurp` |
| `wl-copy` | No | Yes | Install | `wl-clipboard` |
| `cliphist` | No | Yes | Install | `cliphist` |
| `kanshi` | No | Yes | Install | `kanshi` |
