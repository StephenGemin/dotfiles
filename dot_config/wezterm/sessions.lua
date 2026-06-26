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
-- wezterm config. bindings.lua merges `M.keys` into the main key table.
-- =============================================================================

local PLUGIN_URL = 'https://github.com/StephenGemin/resurrect.wezterm'

local M = { keys = {} }

local ok, resurrect = pcall(wezterm.plugin.require, PLUGIN_URL)
if not ok then
  wezterm.log_warn('resurrect.wezterm failed to load: ' .. tostring(resurrect))
  return M
end

-- autosave every 15 min, and resume the most recently saved workspace on launch
resurrect.state_manager.periodic_save({ interval_seconds = 900 })
wezterm.on('gui-startup', resurrect.state_manager.resurrect_on_gui_startup)

M.keys = {
  -- save the current workspace to disk
  {
    key = 'S',
    mods = 'LEADER',
    action = wezterm.action_callback(function(win, pane)
      resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
    end),
  },
  -- restore a saved session (fuzzy picker)
  {
    key = 'R',
    mods = 'LEADER',
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
        local state_type = string.match(id, '^([^/]+)')
        id = string.match(id, '([^/]+)$')
        id = string.match(id, '(.+)%..+$')
        local opts = {
          relative = true,
          restore_text = true,
          on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        }
        if state_type == 'workspace' then
          resurrect.workspace_state.restore_workspace(resurrect.state_manager.load_state(id, 'workspace'), opts)
        elseif state_type == 'window' then
          resurrect.window_state.restore_window(pane:window(), resurrect.state_manager.load_state(id, 'window'), opts)
        elseif state_type == 'tab' then
          resurrect.tab_state.restore_tab(pane:tab(), resurrect.state_manager.load_state(id, 'tab'), opts)
        end
      end)
    end),
  },
  -- delete a saved session (fuzzy picker)
  {
    key = 'D',
    mods = 'LEADER',
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
        resurrect.state_manager.delete_state(id)
      end, {
        title = 'Delete a saved session',
        description = 'Select a session to delete  (Enter = delete, Esc = cancel, / = filter)',
        is_fuzzy = true,
      })
    end),
  },
}

return M
