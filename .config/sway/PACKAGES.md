# Wayland/Sway Packages (Arch Linux)

This file is intentionally limited to Sway/Wayland-related packages.

## Required

```bash
sudo pacman -S --needed \
  sway swaybg swaylock swayidle \
  grim slurp wl-clipboard cliphist wtype jq \
  rofi kanshi brightnessctl swayimg mpv yt-dlp playerctl dunst \
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk
```

What these cover:
- `sway` + `swaymsg`: compositor/window manager and IPC client.
- `swaybg`: wallpaper backend used in your config.
- `swaylock` / `swayidle`: lock and idle handling.
- `grim` + `slurp` + `wl-clipboard`: Wayland screenshot + clipboard flow.
- `mpv`: video player (default for `video/mp4` in mimeapps.list; its .desktop claims the other video types) and `$mod+y` (`play-youtube.fish`: rofi URL/quality -> mpv via yt-dlp).
- `cliphist`: Wayland clipboard history used in your `$mod+v` bind.
- `yt-dlp`: resolves YouTube streams/subtitles for mpv (`$mod+y`).
- `playerctl`: media keys (play/pause/next/previous).
- `dunst`: notifications (`dunstify` countdown in `screenshot-area.sh`).
- `xdg-desktop-portal-wlr` + `-gtk`: screencast/screenshot (wlr) and file chooser / open-with (gtk), as set in `.config/xdg-desktop-portal/`; Firefox opens folders and files through the portal so handlers run outside its bwrap sandbox.
- `wtype`: Wayland-native key typing (rofi bookmarks / cliptype helpers).
- `jq`: parses `swaymsg` JSON for saving the current layout into Kanshi config.
- `rofi`: launcher (Wayland support is built in since 2.0; `rofi-wayland` was merged into it).
- `kanshi`: output profiles for multi-monitor setups on Wayland.
- `brightnessctl`: backlight keys (no xbacklight fallback).
- `swayimg`: Wayland image viewer, default for `image/*` in mimeapps.list (imv would clash with renameutils).

## Optional but recommended

```bash
sudo pacman -S --needed xorg-xwayland
```

Install `xorg-xwayland` for the X11 apps still in use here (JetBrains IDEs, SmartGit, IDA).

Text editor: NotepadNext comes from appman (`appman -i notepadnext`); mimeapps.list
points text/json types at its generated `notepadnext-AM.desktop`.

## AppImages (appman)

GUI apps that are not in pacman come from [appman](https://github.com/ivan-hc/AM)
into `~/appimages`. `.config/appman/am-clone.source` is the list of managed apps;
restore it on a new machine with:

```bash
CLONE_FILE=~/.config/appman/am-clone.source appman --clone -i
```

The list is a snapshot: after `appman -i`/`-r`, regenerate it and commit:

```bash
rm ~/.config/appman/am-clone.source && SCRIPTDIR=~/.config/appman appman --clone
```
