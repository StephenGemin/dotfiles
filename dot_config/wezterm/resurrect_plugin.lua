local wezterm = require('wezterm')

-- =============================================================================
-- resurrect.wezterm -- save / restore / delete session state (workspaces,
-- windows, tabs, panes), with periodic autosave and restore-on-startup.
--
-- Integration follows the upstream MLFlexer/resurrect.wezterm README, EXCEPT
-- encryption: set_encryption is never called, so state is written as plaintext
-- JSON. README: https://github.com/MLFlexer/resurrect.wezterm
--
-- wezterm fetches the plugin at runtime via wezterm.plugin.require, so there is
-- no chezmoi external to manage. The require is pcall-guarded so a failed fetch
-- (e.g. offline) never breaks the rest of the wezterm config. bindings.lua
-- merges `M.keys` into the main key table; wezterm.lua calls `M.setup(config)`
-- to start periodic saves and restore-on-startup.
-- =============================================================================

local PLUGIN_URL = 'https://github.com/MLFlexer/resurrect.wezterm'

-- No-op default so wezterm.lua can call M.setup(config) safely even when the
-- plugin fails to load (pcall returns early below).
local M = { keys = {}, setup = function() end }

local ok, resurrect = pcall(wezterm.plugin.require, PLUGIN_URL)
if not ok then
  wezterm.log_warn('resurrect.wezterm failed to load: ' .. tostring(resurrect))
  return M
end

-- Event listeners (README): toast on errors and on save completion, while
-- keeping the periodic autosave silent via the is_periodic_save flag.
local resurrect_event_listeners = {
  'resurrect.error',
  'resurrect.state_manager.save_state.finished',
}
local is_periodic_save = false
wezterm.on('resurrect.periodic_save', function()
  is_periodic_save = true
end)
for _, event in ipairs(resurrect_event_listeners) do
  wezterm.on(event, function(...)
    if event == 'resurrect.state_manager.save_state.finished' and is_periodic_save then
      is_periodic_save = false
      return
    end
    local args = { ... }
    local msg = event
    for _, v in ipairs(args) do
      msg = msg .. ' ' .. tostring(v)
    end
    wezterm.gui.gui_windows()[1]:toast_notification('Wezterm - resurrect', msg, nil, 4000)
  end)
end

-- Called from wezterm.lua: periodic autosave + restore-on-startup (README).
-- `config` is unused -- these register globally, not via the config object.
function M.setup(config) -- luacheck: ignore config
  resurrect.state_manager.periodic_save({
    interval_seconds = 900,
    save_workspaces = true,
    save_windows = true,
    save_tabs = true,
  })
  wezterm.on('gui-startup', resurrect.state_manager.resurrect_on_gui_startup)
  -- Encryption intentionally omitted: resurrect.state_manager.set_encryption{...}
  -- is not called, so session state is plaintext JSON.
end

-- Keybindings (README, ALT-based). bindings.lua merges these into config.keys.
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
  -- save the current workspace + window together
  {
    key = 's',
    mods = 'ALT',
    action = wezterm.action_callback(function(win, pane)
      resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
      resurrect.window_state.save_window_action()
    end),
  },
  -- restore a saved workspace / window / tab (fuzzy finder)
  {
    key = 'r',
    mods = 'ALT',
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
        local type = string.match(id, '^([^/]+)') -- match before '/'
        id = string.match(id, '([^/]+)$') -- match after '/'
        id = string.match(id, '(.+)%..+$') -- remove file extension
        local opts = {
          relative = true,
          restore_text = true,
          on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        }
        if type == 'workspace' then
          local state = resurrect.state_manager.load_state(id, 'workspace')
          resurrect.workspace_state.restore_workspace(state, opts)
        elseif type == 'window' then
          local state = resurrect.state_manager.load_state(id, 'window')
          resurrect.window_state.restore_window(pane:window(), state, opts)
        elseif type == 'tab' then
          local state = resurrect.state_manager.load_state(id, 'tab')
          resurrect.tab_state.restore_tab(pane:tab(), state, opts)
        end
      end)
    end),
  },
  -- delete a saved state (fuzzy finder)
  {
    key = 'd',
    mods = 'ALT',
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
        resurrect.state_manager.delete_state(id)
      end, {
        title = 'Delete State',
        description = 'Select State to Delete and press Enter = accept, Esc = cancel, / = filter',
        fuzzy_description = 'Search State to Delete: ',
        is_fuzzy = true,
      })
    end),
  },
}

return M
