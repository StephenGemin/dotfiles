local wezterm = require('wezterm')

-- =============================================================================
-- resurrect.wezterm -- save / restore / delete session state (workspaces,
-- windows, tabs, panes) with autosave, restore-on-startup, and full visibility
-- into every event the plugin emits.
--
-- Tracks the UPSTREAM archived repo (MLFlexer/resurrect.wezterm) to exercise the
-- plugin's out-of-the-box behavior. Upstream has no setup() entry point, so
-- every piece is wired here by hand:
--
--   * keybindings    -- save workspace/window/tab, restore (fuzzy), delete (fuzzy)
--   * periodic_save  -- autosave workspaces/windows/tabs on a 15 min timer
--   * gui-startup    -- restore the most recent saved state when wezterm launches
--   * event hooks    -- listen to every emitted trigger and surface it as a
--                       toast, plus a dedicated error handler
--   * set_max_nlines -- cap saved scrollback so state files stay reasonable
--
-- ENCRYPTION IS INTENTIONALLY EXCLUDED. set_encryption is never called (state is
-- written as plaintext JSON) and the resurrect.file_io.encrypt/decrypt.* events
-- are intentionally NOT wired. To enable encryption later: call
-- resurrect.state_manager.set_encryption{...} in M.setup and add the encrypt/
-- decrypt events to `toast_events` below.
--
-- The require is pcall-guarded so a failed fetch (e.g. offline) never breaks the
-- rest of the wezterm config. bindings.lua merges `M.keys` into the main key
-- table; wezterm.lua calls `M.setup(config)` to activate autosave and restore.
-- =============================================================================

local PLUGIN_URL = 'https://github.com/MLFlexer/resurrect.wezterm'

-- No-op defaults so wezterm.lua / bindings.lua can use M unconditionally even
-- when the plugin fails to load (pcall returns early below).
local M = { keys = {}, setup = function() end }

local ok, resurrect = pcall(wezterm.plugin.require, PLUGIN_URL)
if not ok then
  wezterm.log_warn('resurrect.wezterm failed to load: ' .. tostring(resurrect))
  return M
end

-- -----------------------------------------------------------------------------
-- Event triggers
--
-- resurrect emits a paired .start/.finished event around every operation. We
-- listen to all of them (minus the encryption events) and surface each as a
-- toast, so it is obvious what the plugin is doing -- useful while learning how
-- it behaves. Trim `toast_events` if the notifications get noisy.
-- -----------------------------------------------------------------------------

-- Dedicated error handler: log loudly and toast so failures are never silent.
wezterm.on('resurrect.error', function(err)
  wezterm.log_error('resurrect.wezterm error: ' .. tostring(err))
  local windows = wezterm.gui.gui_windows()
  if #windows > 0 then
    windows[1]:toast_notification('resurrect.wezterm', 'ERROR: ' .. tostring(err), nil, 6000)
  end
end)

-- The 15 min autosave fires write_state/sanitize_json on a timer; flip this flag
-- around the periodic save so those high-frequency events stay quiet.
local is_periodic_save = false
wezterm.on('resurrect.state_manager.periodic_save.start', function()
  is_periodic_save = true
end)
wezterm.on('resurrect.state_manager.periodic_save.finished', function()
  is_periodic_save = false
end)

-- Every emitted trigger except the encryption pair
-- (resurrect.file_io.encrypt/decrypt.*), which is excluded by design.
local toast_events = {
  'resurrect.fuzzy_loader.fuzzy_load.start',
  'resurrect.fuzzy_loader.fuzzy_load.finished',
  'resurrect.state_manager.load_state.start',
  'resurrect.state_manager.load_state.finished',
  'resurrect.state_manager.delete_state.start',
  'resurrect.state_manager.delete_state.finished',
  'resurrect.file_io.write_state.start',
  'resurrect.file_io.write_state.finished',
  'resurrect.file_io.sanitize_json.start',
  'resurrect.file_io.sanitize_json.finished',
  'resurrect.tab_state.restore_tab.start',
  'resurrect.tab_state.restore_tab.finished',
  'resurrect.window_state.restore_window.start',
  'resurrect.window_state.restore_window.finished',
  'resurrect.workspace_state.restore_workspace.start',
  'resurrect.workspace_state.restore_workspace.finished',
}

for _, event in ipairs(toast_events) do
  wezterm.on(event, function()
    -- keep the timer-driven autosave silent
    if is_periodic_save and (event:find('write_state') or event:find('sanitize_json')) then
      return
    end
    local windows = wezterm.gui.gui_windows()
    if #windows == 0 then
      return
    end
    -- strip the "resurrect." prefix for a tidier toast title
    local label = (event:gsub('^resurrect%.', ''))
    windows[1]:toast_notification('resurrect.wezterm', label, nil, 4000)
  end)
end

-- -----------------------------------------------------------------------------
-- Activation
--
-- Called from wezterm.lua. Turns on the timer-driven autosave and the
-- restore-on-startup hook, and caps saved scrollback. `config` is accepted for
-- call-site symmetry but unused: upstream registers globally via wezterm events.
-- -----------------------------------------------------------------------------
function M.setup(config) -- luacheck: ignore config
  resurrect.state_manager.periodic_save({
    interval_seconds = 900,
    save_workspaces = true,
    save_windows = true,
    save_tabs = true,
  })

  -- Cap scrollback lines persisted per pane so state files stay manageable.
  resurrect.state_manager.set_max_nlines(5000)

  -- Restore the most recent saved state when the GUI starts.
  wezterm.on('gui-startup', resurrect.state_manager.resurrect_on_gui_startup)

  -- NOTE: resurrect.state_manager.set_encryption{...} is intentionally NOT
  -- called -- session state is written as plaintext JSON (encryption excluded).
end

-- -----------------------------------------------------------------------------
-- Keybindings (upstream's recommended ALT-based defaults). bindings.lua merges
-- these into the main key table.
-- -----------------------------------------------------------------------------
M.keys = {
  -- save the current workspace
  {
    key = 'w',
    mods = 'ALT',
    action = wezterm.action_callback(function(win, pane)
      resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
    end),
  },
  -- save the current window
  {
    key = 'W',
    mods = 'ALT',
    action = resurrect.window_state.save_window_action(),
  },
  -- save the current tab
  {
    key = 'T',
    mods = 'ALT',
    action = resurrect.tab_state.save_tab_action(),
  },
  -- restore a saved workspace / window / tab (fuzzy picker)
  {
    key = 'r',
    mods = 'ALT',
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
  -- delete a saved state (fuzzy picker)
  {
    key = 'd',
    mods = 'ALT',
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
