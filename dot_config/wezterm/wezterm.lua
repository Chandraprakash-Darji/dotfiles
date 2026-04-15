-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

wezterm.on("update-right-status", function(window, pane)
    window:set_right_status(window:active_workspace())
end)

-- This table will hold the configuration.
local config = {}
-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.color_scheme = "tokyonight_night"

-- This is where you actually apply your config choices
config.max_fps = 60
config.animation_fps = 60
config.use_fancy_tab_bar = false
config.font = wezterm.font("FiraCode Nerd Font", { weight = "Bold" })
config.font_size = 24
config.line_height = 1.5
config.window_background_opacity = 1
config.macos_window_background_blur = 0
config.window_padding = { left = 20, right = 20, top = 0, bottom = 20 }

config.hide_tab_bar_if_only_one_tab = true
config.tab_and_split_indices_are_zero_based = false
config.window_decorations = "RESIZE | MACOS_FORCE_SQUARE_CORNERS"

config.inactive_pane_hsb = {
    saturation = 0.5,
    brightness = 0.4,
}

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
    {
        key = "9",
        mods = "ALT",
        action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
    },
    { key = "n", mods = "CTRL", action = act.SwitchWorkspaceRelative(1) },
    { key = "p", mods = "CTRL", action = act.SwitchWorkspaceRelative(-1) },
    {
        key = "W",
        mods = "CTRL|SHIFT",
        action = act.PromptInputLine({
            description = wezterm.format({
                { Attribute = { Intensity = "Bold" } },
                { Foreground = { AnsiColor = "Fuchsia" } },
                { Text = "Enter name for new workspace" },
            }),
            action = wezterm.action_callback(function(window, pane, line)
                -- line will be `nil` if they hit escape without entering anything
                -- An empty string if they just hit enter
                -- Or the actual line of text they wrote
                if line then
                    window:perform_action(
                        act.SwitchToWorkspace({
                            name = line,
                        }),
                        pane
                    )
                end
            end),
        }),
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
return config
