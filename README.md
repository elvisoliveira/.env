# ~/.env

Dotfiles for an Arch Linux + sway (Wayland) desktop. `~/.env` is the git repo;
the home dotfiles are symlinks into it (`~/.config`, `~/.local`, `~/.bashrc`,
`~/.inputrc`, `~/.themes`, `~/.icons`, `~/bookmarks`, `~/desktop`).

Stack: sway + swaylock/swayidle/swaybg, kanshi, rofi, dunst, conky (two panels),
WezTerm, fish + bash, tmux, neovim, NotepadNext (AppImage via appman),
Chicago95 GTK theme, Mononoki Nerd Font with anti-aliasing off on purpose.

- `AGENTS.md`: font/theming rules and where each setting lives.
- `.config/sway/PACKAGES.md`, `CURRENT_TOOLS.md`: packages and tools the sway
  config expects.
- `.config/*/.gitignore` files are allow-lists: only the listed configs are
  versioned, everything else under `~/.config` and `~/.local` stays local.

Submodules: `.tmux.conf`, `.vimrc`, `config.fish` (`git submodule update --init`).

Linking a fresh checkout:

```
cd ~/.env && for f in .bashrc .bash_profile .inputrc .config .local .themes .icons \
    bookmarks; do ln -sfn "$PWD/$f" ~/"$f"; done
ln -sfn ~/.env/.tmux.conf/.tmux.conf ~/.tmux.conf
ln -sfn ~/.env/.vimrc/.vimrc ~/.vimrc
ln -sfn ~/.env/.local/share/applications ~/desktop
```
