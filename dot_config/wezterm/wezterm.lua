local wezterm = require('wezterm')
local launch = require('launch')
local bindings = require('bindings')
local resurrect_plugin = require('resurrect_plugin')
require('ui') -- registers the tab-title and status-bar event handlers

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
    return "Solarized Dark - Patched"
  else
    return "Catppuccin Latte"
  end
end

local font = wezterm.font('JetBrains Mono')
config.font = font
config.font_size = 14
config.window_frame = { font = font, font_size = 12 }
local scheme_name = scheme_for_appearance(wezterm.gui.get_appearance())
config.color_scheme = scheme_name

-- Solarized's red (used for git diff removals, among other things) reads too
-- bright/saturated on screen; tone it down while leaving the rest of the
-- scheme's palette untouched.
do
  local scheme = wezterm.color.get_builtin_schemes()[scheme_name]
  if scheme and scheme.ansi and scheme.brights then
    local ansi = {}
    local brights = {}
    for i, c in ipairs(scheme.ansi) do ansi[i] = c end
    for i, c in ipairs(scheme.brights) do brights[i] = c end
    ansi[2] = '#9c4b48'
    brights[2] = '#ad5f5c'
    config.colors = { ansi = ansi, brights = brights }
  end
end
config.enable_scroll_bar = true
config.use_fancy_tab_bar = false
config.tab_max_width = 25
config.default_cursor_style = 'BlinkingUnderline'
config.initial_rows = 50
config.initial_cols = 140
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 10000
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.8 }

-- keep the default link detection and also linkify additional URL forms
config.hyperlink_rules = wezterm.default_hyperlink_rules()
for _, rule in ipairs({
  -- bare www. hostnames, e.g. www.example.com
  { regex = [[\bwww\.[\w.-]+\.[a-z]{2,15}\S*\b]], format = 'https://$0' },
  -- a URL in parens: (URL)
  { regex = [[\((\w+://\S+)\)]], format = '$1', highlight = 1 },
  -- a URL in brackets: [URL]
  { regex = [=[\[(\w+://\S+)\]]=], format = '$1', highlight = 1 },
  -- a URL in curly braces: {URL}
  { regex = [[\{(\w+://\S+)\}]], format = '$1', highlight = 1 },
  -- a URL in angle brackets: <URL>
  { regex = [[<(\w+://\S+)>]], format = '$1', highlight = 1 },
  -- implicit mailto link for bare email addresses
  { regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]], format = 'mailto:$0' },
}) do
  table.insert(config.hyperlink_rules, rule)
end

config.default_prog = launch.default_prog
config.launch_menu = launch.launch_menu

config.leader = bindings.leader
config.keys = bindings.keys
config.mouse_bindings = bindings.mouse_bindings

resurrect_plugin.setup(config) -- wires up periodic autosave and restore-on-startup

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
