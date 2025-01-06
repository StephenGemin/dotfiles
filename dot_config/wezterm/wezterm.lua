local wezterm = require('wezterm')
local launch = require('launch')
local bindings = require('bindings')

-- Allow working with both the current release and the nightly
local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.disable_default_key_bindings = true

-- set theme based on system theme
-- https://github.com/catppuccin/wezterm
local function scheme_for_appearance(appearance)
  if appearance:find "Dark" then
    return "Catppuccin Macchiato"
  else
    return "Catppuccin Latte"
  end
end

local font = wezterm.font('JetBrains Mono')
config.font = font
config.font_size = 14
config.window_frame = { font = font, font_size = 12 }
config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.enable_scroll_bar = true
config.use_fancy_tab_bar = false
config.tab_max_width = 25
config.default_cursor_style = 'BlinkingUnderline'
config.initial_rows = 50
config.initial_cols = 140
config.hide_tab_bar_if_only_one_tab = true

config.default_prog = launch.default_prog
config.launch_menu = launch.launch_menu

config.leader = bindings.leader
config.keys = bindings.keys
config.mouse_bindings = bindings.mouse_bindings

config.automatically_reload_config = true
config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = 'NeverPrompt'
config.audible_bell = "Disabled"
config.switch_to_last_active_tab_when_closing_tab = true
config.exit_behavior = 'CloseOnCleanExit'  -- if the shell program exited with a successful status
config.exit_behavior_messaging = 'Verbose'

-- -- do not use for unix systems refer to https://github.com/wez/wezterm/issues/2933
-- if wezterm.target_triple:find("windows") then
--  -- multiplexing
--  config.unix_domains =  {
--    { name = 'unix' },
--  }
--
--  -- This causes `wezterm` to act as though it was started as
--  -- `wezterm connect unix` by default, connecting to the unix
--  -- domain on startup.
--  -- If you prefer to connect manually, leave out this line.
--  config.default_gui_startup_args = { 'connect', 'unix' }
-- end

return config
