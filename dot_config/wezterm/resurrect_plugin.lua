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

-- https://github.com/StephenGemin/resurrect.wezterm#basic-setup
function M.setup(config)
  resurrect.setup(config, {
    periodic_interval = 300,
    save_windows=false,  -- no periodic save of windows
    save_tabs=false,  -- no periodic save of tabs
    status_bar = false,
  })
end

return M
