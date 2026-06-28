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
-- 10 min and startup restore. We lean on the plugin's defaults as much as
-- possible (save_workspaces/windows/tabs all default true), and only override
-- keybindings and status_bar: we use custom LEADER bindings (below) and ui.lua
-- owns the status bar.
function M.setup(config)
  resurrect.setup(config, {
    periodic_interval = 600,
    keybindings = false,
    status_bar = false,
  })
end

-- These use the plugin's built-in action helpers rather than hand-rolled
-- callbacks. restore_action auto-detects the saved state type (workspace /
-- window / tab) from the picker selection and dispatches accordingly.
M.keys = {
  -- save the current workspace to disk
  {
    key = 'S',
    mods = 'LEADER',
    action = resurrect.workspace_state.save_workspace_action(),
  },
  -- restore a saved session (fuzzy picker; auto-detects workspace/window/tab)
  {
    key = 'R',
    mods = 'LEADER',
    action = resurrect.fuzzy_loader.restore_action({
      relative = true,
      restore_text = true,
      on_pane_restore = resurrect.tab_state.default_on_pane_restore,
    }),
  },
  -- delete a saved session (fuzzy picker)
  {
    key = 'D',
    mods = 'LEADER',
    action = resurrect.fuzzy_loader.delete_action(),
  },
}

return M
