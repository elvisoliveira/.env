# AGENTS.md — ~/.env dotfiles

Personal dotfiles repo. Wayland/sway desktop on Arch Linux. This file documents
the **font configuration** across the system so it stays consistent and any agent
(or human) editing fonts knows every place that needs to change.

## Font philosophy

- **Sharp / no anti-aliasing on purpose.** Rendering is intentionally aliased for
  a crisp, retro look that fits the Chicago95 GTK theme. Do **not** re-enable
  anti-aliasing globally to "fix" rendering — it is a deliberate choice.
- **Standardized on Mononoki Nerd Font.** One Nerd Font everywhere: it carries
  its own icon glyphs (no separate symbols font needed) and was validated to
  render acceptably in Chromium DevTools / Electron with anti-aliasing off.
  - **Mononoki Nerd Font Mono** → monospace contexts (terminal, editor, devtools
    DOM tree, web `monospace`). The `Mono` variant is fixed-width.
  - **Mononoki Nerd Font** → UI / proportional contexts (GTK, window titles,
    status bar, web `sans-serif`).
- Package: `ttf-mononoki-nerd`. Keep it installed — it is the system standard.

## Where fonts are configured

| Scope | File | Setting | Value |
|-------|------|---------|-------|
| fontconfig render | `.config/fontconfig/fonts.conf` | `antialias` | `false` (sharp — keep) |
| fontconfig generics | `.config/fontconfig/fonts.conf` | `monospace` alias (`<prefer>`) | Mononoki Nerd Font Mono |
| fontconfig generics | `.config/fontconfig/fonts.conf` | `sans-serif` (`<match>` strong prepend) | Mononoki Nerd Font |
| GTK 3 | `.config/gtk-3.0/settings.ini` | `gtk-font-name` | Mononoki Nerd Font 11 |
| sway window titles | `.config/sway/config` (~line 10) | `font pango:` | Mononoki Nerd Font 11 |
| swaybar (workspaces, `mode hide`) | `.config/sway/config` (`bar {}`) | `font pango:` | Mononoki Nerd Font 11 |
| WezTerm terminal (`$term` in sway) | `.config/wezterm/wezterm.lua` | `config.font` + `freetype_load_target = "Mono"` (aliased) | Mononoki Nerd Font Mono |
| SciTE editor | `.SciTEUser.properties` | `font.monospace` | `Courier New` → falls back to Mononoki Nerd Font Mono via fontconfig |
| gVim GUI | `.vimrc/.vimrc` | `set guifont` | `Fira Mono Medium 10` → falls back to Mononoki Nerd Font Mono (Fira not installed) |

### Why `sans-serif` needs a `<match>`, not a `<prefer>` alias

Mononoki is a monospace font (`spacing=100`). A `<prefer>` alias adds it with
**weak** binding, so a proportional font (FreeSans) still outranks it for the
`sans-serif` generic. The fix is a strong-binding prepend:

```xml
<match target="pattern">
    <test name="family"><string>sans-serif</string></test>
    <edit name="family" mode="prepend" binding="strong">
        <string>Mononoki Nerd Font</string>
    </edit>
</match>
```

`monospace` works with a plain `<prefer>` alias because the spacing constraint
already favors the mono font.

### Browsers (Chromium / Firefox)

No per-app font config. Both resolve the web generic families (`monospace`,
`sans-serif`) through fontconfig, so the aliases in
`.config/fontconfig/fonts.conf` control them. Restart the browser after changing
fontconfig — Chromium/Firefox read it only at startup. The Chromium DevTools DOM
tree uses `monospace`; that is why the monospace alias matters there.

## Icon glyphs (status bar)

Mononoki Nerd Font includes Nerd Font icon glyphs, so the swaybar / conky
status line gets both text and icons from the single font — no separate symbols
font in the Pango string. (`ttf-nerd-fonts-symbols-mono` may be installed from an
earlier experiment; it is unused by the current config and can be removed.)

## Not font config (ignore when sweeping)

- `.local/share/icons/Chicago95/**/icons.html` — vendored theme gallery pages.
- `.vimrc/markdown-preview.css` — vendored GitHub-style markdown CSS.

## Applying changes

- **fontconfig**: `fc-cache -f`, then restart affected apps (browsers, Electron).
- **sway**: `swaymsg reload` (or `Mod+Shift+c`).
- **GTK**: reopen the app; running apps don't reload `settings.ini`.
- **WezTerm**: live-reloads its Lua on save; open windows pick it up.

## Verifying what a generic resolves to

```
fc-match monospace      # -> Mononoki Nerd Font Mono
fc-match sans-serif     # -> Mononoki Nerd Font
```

## History / rationale

An earlier attempt standardized on the Liberation family (Liberation Sans/Mono)
plus `Symbols Nerd Font Mono` for bar icons, because Mononoki looked thin without
anti-aliasing. After side-by-side testing in Chromium DevTools, Mononoki was kept
everywhere instead — it renders acceptably and keeps the single-Nerd-Font setup.
The original DevTools complaint was actually `FreeMono` (the unstyled `monospace`
default), not Mononoki; aliasing `monospace` away from FreeMono is what fixed it.
