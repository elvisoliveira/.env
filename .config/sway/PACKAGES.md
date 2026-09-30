# Wayland/Sway Packages (Arch Linux)

This file is intentionally limited to Sway/Wayland-related packages.

## Required

```bash
sudo pacman -S --needed \
  sway swaybg swaylock swayidle \
  grim slurp wl-clipboard cliphist wtype jq \
  satty rofi-wayland kanshi
```

What these cover:
- `sway` + `swaymsg`: compositor/window manager and IPC client.
- `swaybg`: wallpaper backend used in your config.
- `swaylock` / `swayidle`: lock and idle handling.
- `grim` + `slurp` + `wl-clipboard`: Wayland screenshot + clipboard flow.
- `satty`: screenshot annotator (`$mod+Shift+s` bind: slurp -> grim -> satty; salva + copia path).
- `cliphist`: Wayland clipboard history used in your `$mod+v` bind.
- `wtype`: Wayland-native key typing used by your question-mark helper binding.
- `jq`: parses `swaymsg` JSON for saving the current layout into Kanshi config.
- `rofi-wayland`: launcher on Wayland.
- `kanshi`: output profiles for multi-monitor setups on Wayland.

## Optional but recommended

```bash
sudo pacman -S --needed xorg-xwayland
```

Install `xorg-xwayland` if you run X11 apps under Sway.
