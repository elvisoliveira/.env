-- WezTerm config mirroring ~/.config/alacritty/alacritty.toml (+ dracula.toml),
-- plus native tabs (Ctrl+Tab / Ctrl+Shift+Tab switch, Ctrl+Shift+T new,
-- Ctrl+Shift+W close: all WezTerm defaults, scoped to the WezTerm window).
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- font: same as alacritty; "Mono" load target = no anti-aliasing, matching the
-- system-wide fontconfig antialias=false (see ~/.env/AGENTS.md).
config.font = wezterm.font("Mononoki Nerd Font Mono")
config.font_size = 11
config.freetype_load_target = "Mono"
config.freetype_render_target = "Mono"

-- colors / window
config.color_scheme = "Dracula (Official)"
config.window_background_opacity = 0.7
config.window_decorations = "NONE"          -- sway draws the borders
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.enable_wayland = true

-- tmux forces extended-keys (csi-u) for Ctrl+Shift+<key> in nvim; alacritty
-- spoke the kitty keyboard protocol out of the box, WezTerm needs opt-in.
-- Only activates when an app requests it, so plain shells are unaffected.
config.enable_kitty_keyboard = true

-- cursor: alacritty blinking = Always, blink_interval = 500
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- shell
config.default_prog = { "/bin/bash" }

-- tabs: minimal bar, hidden with a single tab
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.tab_max_width = 32

-- selection.save_to_clipboard = true
config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},
}

-- keyboard.bindings: Shift+Home/End scroll (alacritty mode = ~Alt)
config.keys = {
	{ key = "Home", mods = "SHIFT", action = act.ScrollToTop },
	{ key = "End", mods = "SHIFT", action = act.ScrollToBottom },
	-- Firefox-style tabs: Ctrl+T new, Ctrl+1..8 jump, Ctrl+9 last.
	-- Ctrl+W / Ctrl+N deliberately NOT taken (bash word-delete, vim windows,
	-- history); close/new window stay on the Ctrl+Shift+W / Ctrl+Shift+N defaults.
	{ key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "9", mods = "CTRL", action = act.ActivateTab(-1) },
}
for i = 1, 8 do
	table.insert(config.keys, { key = tostring(i), mods = "CTRL", action = act.ActivateTab(i - 1) })
end

return config
