local wezterm = require('wezterm')

-- =============================================================================
-- resurrect.wezterm -- save / restore / delete session state (windows, tabs,
-- panes), plus autosave and resume-on-startup.
--
-- NOTE: this points at a personal FORK. The upstream repo
-- (MLFlexer/resurrect.wezterm) is archived/unmaintained, so we use
-- https://github.com/StephenGemin/resurrect.wezterm instead.
--
-- All resurrect.wezterm configuration lives in this file. The plugin require is
-- pcall-guarded so a failed fetch (e.g. offline) never breaks the rest of the
-- wezterm config. bindings.lua merges `M.keys` into the main key table, and
-- wezterm.lua calls `M.setup(config)` to activate periodic saves and startup
-- restore.
-- =============================================================================

local PLUGIN_URL = 'https://github.com/StephenGemin/resurrect.wezterm'

-- setup is a no-op default so wezterm.lua can always call M.setup(config)
-- safely even when the plugin fails to load (pcall returns early below).
local M = { keys = {}, setup = function() end }

local ok, resurrect = pcall(wezterm.plugin.require, PLUGIN_URL)
if not ok then
  wezterm.log_warn('resurrect.wezterm failed to load: ' .. tostring(resurrect))
  return M
end

-- Called from wezterm.lua with the config object. Enables periodic saves every
-- 10 min, startup restore, and the plugin's default keybindings
-- (Alt + W/S/Shift+W/Shift+T/R/D). status_bar stays off because ui.lua owns the
-- status bar.
function M.setup(config)
  resurrect.setup(config, {
    periodic_interval = 600,
    status_bar = false,
  })
end

-- M.keys is left empty (default from the M table above): the plugin installs
-- its own bindings via setup(), so bindings.lua's merge loop is a no-op.

return M
