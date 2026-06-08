# QMK keymaps (versioned)

Only the **custom keymaps** live here. The full QMK source tree (~1.6 GB) is a
separate clone at `~/.env/qmk_keychron/`, which is its own git repo and is
gitignored — we don't version upstream QMK, just our `keymap.c`.

The build tree finds each keymap through a **symlink** that points back here, so
this file is the single source of truth: edit it, rebuild, commit.

```
~/.env/qmk/keyboards/.../brabnt/keymap.c        <- real file (tracked)
~/.env/qmk_keychron/keyboards/.../brabnt/keymap.c  -> symlink to the above
```

## Keyboards

- **Keychron K3 v3** (ANSI, white / LED-matrix) — keymap `brabnt`
  (`keyboards/keychron/k3_version_3/ansi/white/keymaps/brabnt`).
  ABNT2 helpers + Ctrl+Up/Down → PageUp/PageDown.

## After cloning .env on a new machine

1. Clone the QMK tree the firmware expects into `~/.env/qmk_keychron/`.
2. Recreate the symlinks:

   ```sh
   ~/.env/qmk/link.sh
   ```

## Build & flash (Keychron K3 v3)

```sh
cd ~/.env/qmk_keychron
qmk compile -kb keychron/k3_version_3/ansi/white -km brabnt
# Put the keyboard in flash mode: slider to "Cable", hold Esc while plugging USB-C.
qmk flash   -kb keychron/k3_version_3/ansi/white -km brabnt
```
