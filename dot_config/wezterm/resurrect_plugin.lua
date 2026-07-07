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

local M = { keys = {}, setup = function() end }

-- setup is a no-op default so wezterm.lua can always call M.setup(config)
-- safely even when the plugin fails to load (pcall returns early below).
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

-- Code below was used to debug some resurrect restore behaviour.  Keep this here for future reference.
-- -- =============================================================================
-- -- TEMPORARY -- branch A (spawn x switch restore normalization) live-debug harness.
-- -- Revert, or split into its own chezmoi branch, once branch A is verified.
-- --
-- -- Requires the branch checkout's plugin/resurrect/workspace_state.lua copied into
-- -- the wezterm plugin cache, then a full relaunch:
-- --   CACHE="$HOME/Library/Application Support/wezterm/plugins/httpssCssZssZsgithubsDscomsZsStephenGeminsZsresurrectsDswezterm"
-- --   cp plugin/resurrect/workspace_state.lua "$CACHE/plugin/resurrect/"
-- --
-- -- Fixture: create + save a workspace named TEST_WS first --
-- --   Alt+Shift+N (name it TEST_WS), split a couple panes, Alt+W to save.
-- -- Then drive the cells from a DIFFERENT current workspace where TEST_WS is not
-- -- live. LEADER is CTRL+Space.
-- --
-- --   LEADER+1  T/T  spawn into + switch to TEST_WS (default)
-- --   LEADER+2  T/F  spawn into TEST_WS, stay put -- LEADER+0 must show ONE TEST_WS (collision fix)
-- --   LEADER+3  F/F  spawn into current, rename current -> TEST_WS (legacy)
-- --   LEADER+4  F/T  spawn into TEST_WS (forced) + switch -- must NOT crash
-- --   LEADER+0  log the live workspace names to the debug overlay (F12)
-- -- =============================================================================
-- local TEST_WS = 'test'

-- local function ws_names()
--   return table.concat(wezterm.mux.get_workspace_names(), ', ')
-- end

-- -- Per-workspace window + pane counts, e.g. "03: 1w/2p, test: 1w/4p".
-- -- Groups live mux windows by workspace so BEFORE/AFTER shows where windows and
-- -- panes actually landed, not just which workspace names exist.
-- local function ws_summary()
--   local windows, panes, order = {}, {}, {}
--   for _, mux_win in ipairs(wezterm.mux.all_windows()) do
--     local ws = mux_win:get_workspace()
--     if windows[ws] == nil then
--       windows[ws], panes[ws] = 0, 0
--       table.insert(order, ws)
--     end
--     windows[ws] = windows[ws] + 1
--     for _, tab in ipairs(mux_win:tabs()) do
--       panes[ws] = panes[ws] + #tab:panes()
--     end
--   end
--   local parts = {}
--   for _, ws in ipairs(order) do
--     table.insert(parts, string.format('%s: %dw/%dp', ws, windows[ws], panes[ws]))
--   end
--   return table.concat(parts, ', ')
-- end

-- local function restore_cell(label, cell_opts)
--   return wezterm.action_callback(function(_win, _pane)
--     local target_live = false
--     for _, name in ipairs(wezterm.mux.get_workspace_names()) do
--       if name == TEST_WS then
--         target_live = true
--       end
--     end
--     wezterm.log_info(string.format(
--       'resurrect test [%s] BEFORE: active=%q, target %q live=%s, opts=%s, live=[%s], counts=[%s]',
--       label, wezterm.mux.get_active_workspace(), TEST_WS, tostring(target_live),
--       wezterm.json_encode(cell_opts), ws_names(), ws_summary()
--     ))

--     local opts = {
--       relative = true,
--       restore_text = true,
--       on_pane_restore = resurrect.tab_state.default_on_pane_restore,
--     }
--     for k, v in pairs(cell_opts) do
--       opts[k] = v
--     end

--     local ok_restore, err = pcall(function()
--       resurrect.workspace_state.restore_workspace(
--         resurrect.state_manager.load_state(TEST_WS, 'workspace'),
--         opts
--       )
--     end)
--     if not ok_restore then
--       wezterm.log_error('resurrect test [' .. label .. '] restore raised: ' .. tostring(err))
--     end

--     wezterm.log_info(string.format(
--       'resurrect test [%s] AFTER: active=%q, live=[%s], counts=[%s]',
--       label, wezterm.mux.get_active_workspace(), ws_names(), ws_summary()
--     ))
--   end)
-- end

-- local test_keys = {
--   { key = '1', mods = 'LEADER', action = restore_cell('1 T/T', {}) },
--   { key = '2', mods = 'LEADER', action = restore_cell('2 T/F', { switch_workspace = false }) },
--   { key = '3', mods = 'LEADER', action = restore_cell('3 F/F', { spawn_in_workspace = false }) },
--   { key = '4', mods = 'LEADER', action = restore_cell('4 F/T', { spawn_in_workspace = false, switch_workspace = true }) },
--   {
--     key = '0',
--     mods = 'LEADER',
--     action = wezterm.action_callback(function()
--       wezterm.log_info('resurrect test: active=' .. wezterm.mux.get_active_workspace() .. ', workspaces = [' .. ws_names() .. ']')
--     end),
--   },
-- }
-- for _, k in ipairs(test_keys) do
--   table.insert(M.keys, k)
-- end

return M
