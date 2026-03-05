-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}
-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = 'tokyonight_night'

-- This is where you actually apply your config choices
config.max_fps = 144
config.animation_fps = 144
config.use_fancy_tab_bar = false
config.font = wezterm.font("FiraCode Nerd Font", { weight = "Bold" })
config.font_size = 25
config.line_height = 1.5
config.window_background_opacity = 0.96
config.macos_window_background_blur = 10
config.window_padding = { left = 20, right = 20, top = 0, bottom = 20 }

config.hide_tab_bar_if_only_one_tab = true
config.tab_and_split_indices_are_zero_based = false
config.window_decorations = "RESIZE"

config.keys = {
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		key = "l",
		mods = "SUPER|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "h",
		mods = "SUPER|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "SUPER|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "SUPER|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "s",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "d",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "w",
		mods = "SUPER",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
}

function Recompute_font_size(window)
	local My_font_size = 12.0
	local Font_size = My_font_size
	local window_dims = window:get_dimensions()
	local overrides = window:get_config_overrides() or {}

	if window_dims.pixel_width == 1920 then
		Font_size = 12
	elseif window_dims.pixel_width < 1920 then
		Font_size = 10
	end

	overrides.font_size = Font_size
	overrides.line_height = Font_size / 8

	window:set_config_overrides(overrides)
end

local mux = wezterm.mux

wezterm.on("gui-startup", function()
	local _, servers_pane, window = mux.spawn_window({
		cwd = wezterm.home_dir,
	})

	local gui_window = window:gui_window()
	-- gui_window:perform_action(wezterm.action.ToggleFullScreen, servers_pane)
	-- gui_window:maximize()
	Recompute_font_size(gui_window)
end)

wezterm.on("window-resized", function(window)
	Recompute_font_size(window)
end)
-- tab bar style
-- -- The filled in variant of the < symbol
-- local SOLID_LEFT_ARROW = wezterm.nerdfonts.nf_ple_upper_left_triangle
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle

-- The filled in variant of the > symbol
-- local SOLID_RIGHT_ARROW = wezterm.nerdfonts.nf_ple_upper_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle
local SLASH = wezterm.nerdfonts.fae_slash
local ARROW_EXPAND_RIGHT = wezterm.nerdfonts.md_arrow_expand_right

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

-- Attempt to retrieve the active color scheme's foreground/background
local function get_scheme_colors(name)
	local schemes = {}
	if wezterm.color and wezterm.color.get_builtin_schemes then
		schemes = wezterm.color.get_builtin_schemes()
	elseif wezterm.get_builtin_color_schemes then
		schemes = wezterm.get_builtin_color_schemes()
	end

	local scheme = schemes[name or config.color_scheme] or {}
	local bg = scheme.background or (scheme.colors and scheme.colors.background)
	local fg = scheme.foreground or (scheme.colors and scheme.colors.foreground)

	return {
		background = bg or "#1e1e1e",
		foreground = fg or "#ffffff",
	}
end

local colors = get_scheme_colors(config.color_scheme)

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
	local edge_background = colors.background or "#1e1e1e"
	local background = colors.background or "#1e1e1e"
	local foreground = colors.foreground or "#ffffff"

	if tab.is_active then
		background = colors.foreground or "#ffffff"
		foreground = colors.background or "#1e1e1e"
	elseif hover then
		background = "#1b1b32"
		foreground = "#909090"
	end

	local edge_foreground = background

	local title = tab_title(tab)

	-- ensure that the titles fit in the available space,
	-- and that we have room for the edges.
	title = wezterm.truncate_right(title, max_width - 2)

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = "  " .. tab.tab_index + 1 .. " " .. ARROW_EXPAND_RIGHT .. " " .. title .. "  " },
		{ Background = { Color = edge_foreground } },
		{ Foreground = { Color = "#909090" } },
		{ Text = SLASH },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

-- and finally, return the configuration to wezterm
return config
