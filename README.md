# ~/.env

Dotfiles for an Arch Linux + sway (Wayland) desktop. `~/.env` is the git repo;
a few home entries are symlinks into it (`~/.config`, `~/.local`, `~/.bashrc`,
`~/.bash_profile`, `~/bookmarks`, `~/desktop`). Everything else is reached
through `~/.config` (tmux ≥3.1 reads `~/.config/tmux/tmux.conf`, readline via
`INPUTRC`, npm via `NPM_CONFIG_USERCONFIG`, nvim's `init.vim` sources
`~/.config/nvim/vimrc`), so there is no `~/.tmux.conf`, `~/.vimrc` or `~/.inputrc`.

Stack: sway + swaylock/swayidle/swaybg, kanshi, rofi, dunst, conky (two panels),
WezTerm, fish + bash, tmux, neovim, PCManFM, mpv, NotepadNext (AppImage via appman),
Adwaita dark (built-in GTK theme), Mononoki Nerd Font with anti-aliasing off on purpose.
GUI apps from pacman are GTK3 or toolkit-free only (no Qt, no GTK4).

- `.config/sway/PACKAGES.md`: packages the sway config expects.
- `.config/*/.gitignore` files are allow-lists: only the listed configs are
  versioned, everything else under `~/.config` and `~/.local` stays local.

Submodules: `.tmux.conf`, `.vimrc`, `config.fish` (`git submodule update --init`).

Linking a fresh checkout:

```
cd ~/.env && for f in .bashrc .bash_profile .config .local bookmarks; do
    ln -sfn "$PWD/$f" ~/"$f"; done
ln -sfn ~/.env/.local/share/applications ~/desktop
fish ~/.env/config.fish/install.fish   # fish config: one symlink per file
```

`~/.config/tmux/tmux.conf` and `~/.config/nvim/vimrc` are symlinks into the
`.tmux.conf` and `.vimrc` submodules and live in this repo already.
