local wezterm = require('wezterm')

-- =============================================================================
-- resurrect.wezterm -- save / restore / delete session state (windows, tabs,
-- panes), plus autosave and resume-on-startup.
--
-- NOTE: this points at the UPSTREAM repo (MLFlexer/resurrect.wezterm), which
-- is archived/unmaintained. We track upstream here to see how the plugin
-- behaves out of the box; the personal fork
-- (https://github.com/StephenGemin/resurrect.wezterm) can be swapped back in by
-- changing PLUGIN_URL below.
--
-- All resurrect.wezterm configuration lives in this file. The plugin require is
-- pcall-guarded so a failed fetch (e.g. offline) never breaks the rest of the
-- wezterm config. bindings.lua merges `M.keys` into the main key table, and
-- wezterm.lua calls `M.setup(config)` to activate periodic saves and startup
-- restore.
-- =============================================================================

local PLUGIN_URL = 'https://github.com/MLFlexer/resurrect.wezterm'

-- setup is a no-op default so wezterm.lua can always call M.setup(config)
-- safely even when the plugin fails to load (pcall returns early below).
local M = { keys = {}, setup = function() end }

local ok, resurrect = pcall(wezterm.plugin.require, PLUGIN_URL)
if not ok then
  wezterm.log_warn('resurrect.wezterm failed to load: ' .. tostring(resurrect))
  return M
end

-- Called from wezterm.lua. Upstream MLFlexer has NO setup() entry point -- the
-- fork bundled everything into resurrect.setup(config, opts); upstream requires
-- wiring each piece by hand:
--
--   * periodic_save -> autosave workspaces/windows/tabs on a 15 min (900s) timer
--   * gui-startup   -> restore the most recent saved state when wezterm launches
--
-- Deliberately omitted vs. a full upstream setup:
--   * set_encryption -- NOT called, so state is written as plaintext JSON.
--     Encryption is excluded by request; add resurrect.state_manager
--     .set_encryption{...} here to turn it back on.
--   * keybindings    -- our custom LEADER bindings live in M.keys below.
--   * status bar     -- ui.lua owns the right status bar.
--
-- `config` is accepted (so wezterm.lua can keep calling M.setup(config)
-- unconditionally) but unused: upstream's autosave and restore register
-- globally via wezterm events rather than through the config object.
function M.setup(config) -- luacheck: ignore config
  resurrect.state_manager.periodic_save({
    interval_seconds = 900,
    save_workspaces = true,
    save_windows = true,
    save_tabs = true,
  })
  wezterm.on('gui-startup', resurrect.state_manager.resurrect_on_gui_startup)
end

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
          -- Anchor the restore to the current window so restore_workspace uses
          -- the in-place path rather than spawning a new window into "default".
          opts.window = pane:window()
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
