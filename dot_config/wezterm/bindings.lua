local wezterm = require('wezterm')

local act = wezterm.action
local target_triple = wezterm.target_triple

local mod = {}
local bind = {}

if target_triple:find("darwin") then
  mod.SUPER = 'CTRL'
else
  mod.SUPER = 'CTRL' -- to not conflict with Windows key shortcuts
end

-- Session persistence (save/restore windows, tabs, panes).
-- Upstream resurrect.wezterm is archived but functional; pcall-guard it so a
-- failed plugin fetch (e.g. offline) never breaks the rest of the config.
local resurrect_ok, resurrect = pcall(wezterm.plugin.require, 'https://github.com/MLFlexer/resurrect.wezterm')
if resurrect_ok then
  resurrect.state_manager.periodic_save({ interval_seconds = 900 })
end

-- https://github.com/mrjones2014/smart-splits.nvim
-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == 'true'
end

-- QWERTY
--LEFT = 'h'
--DOWN = 'j'
--UP = 'k'
--RIGHT = 'l'
--local direction_keys = {
--  h = 'Left',
--  j = 'Down',
--  k = 'Up',
--  l = 'Right',
--}

-- Colemak
LEFT = 'n'
DOWN = 'e'
UP = 'i'
RIGHT = 'o'
local direction_keys = {
  n = 'Left',
  e = 'Down',
  i = 'Up',
  o = 'Right',
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'META' or 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

local function activate_tab_by_val(key)
  return { key = tostring(key), mods = 'SUPER', action = act.ActivateTab(key - 1)}
end

-- like nvim leader "space" or tmux ctrl+b
bind.leader = { key = 'Space', mods = mod.SUPER, timeout_milliseconds = 1000 }
bind.keys = {
  -- copy/paste --
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },
  -- quick select: keyboard-driven copy of urls, paths, hashes on screen
  { key = 'Space', mods = 'CTRL|SHIFT', action = act.QuickSelect },

  -- tabs
  -- SpawnTab on CurrentPaneDomain so new tabs inherit the current cwd (OSC 7)
  { key = 't', mods = 'LEADER', action = act.SpawnTab('CurrentPaneDomain') },
  { key = 'w', mods = mod.SUPER, action = act.CloseCurrentTab({ confirm = false }) },

  -- tabs: navigation
  activate_tab_by_val(1),
  activate_tab_by_val(2),
  activate_tab_by_val(3),
  activate_tab_by_val(4),
  activate_tab_by_val(5),
  activate_tab_by_val(6),
  activate_tab_by_val(7),
  activate_tab_by_val(8),
  activate_tab_by_val(9),

  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

  -- tabs: move/reorder the current tab left/right (Colemak n/o, home row)
  { key = 'n', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
  { key = 'o', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },

  -- panes
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane({ confirm = false }) },
  { key = 'Enter', mods = mod.SUPER, action = act.TogglePaneZoomState },
  { key = "PageUp", mods = '', action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = '', action = act.ScrollByPage(1) },

  -- scrollback: jump between shell prompts (needs OSC 133 shell integration)
  { key = 'i', mods = 'CTRL|SHIFT', action = act.ScrollToPrompt(-1) },
  { key = 'e', mods = 'CTRL|SHIFT', action = act.ScrollToPrompt(1) },

  -- panes: splitting
  { key = DOWN, mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = RIGHT, mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  -- panes: naviation
  -- move between split panes
  split_nav('move', LEFT),
  split_nav('move', DOWN),
  split_nav('move', UP),
  split_nav('move', RIGHT),
  -- panes: resize
  split_nav('resize', LEFT),
  split_nav('resize', DOWN),
  split_nav('resize', UP),
  split_nav('resize', RIGHT),

  -- panes: swap the selected pane with the active one
  {
    key = 'p',
    mods = 'CTRL|ALT',
    action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
  },
  -- panes: jump to a pane by label
  { key = 'p', mods = 'LEADER', action = act.PaneSelect({ alphabet = '1234567890' }) },

  -- panes: modal resize (LEADER r, then n/e/i/o to resize, Esc/Enter to exit)
  { key = 'r', mods = 'LEADER', action = act.ActivateKeyTable({ name = 'resize_pane', one_shot = false, timeout_milliseconds = 1500 }) },

  -- workspaces (tmux-style sessions)
  { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) },
  { key = '[', mods = 'LEADER', action = act.SwitchWorkspaceRelative(-1) },
  { key = ']', mods = 'LEADER', action = act.SwitchWorkspaceRelative(1) },
  {
    key = 'c',
    mods = 'LEADER',
    action = act.PromptInputLine({
      description = wezterm.format({
        { Attribute = { Intensity = 'Bold' } },
        { Text = 'Enter name for new workspace' },
      }),
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= '' then
          window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
        end
      end),
    }),
  },

  -- window
  { key = 'n', mods = 'LEADER', action = act.SpawnWindow },
  { key = '=', mods = mod.SUPER, action = act.IncreaseFontSize },
  { key = '-', mods = mod.SUPER, action = act.DecreaseFontSize },
  { key = '0', mods = mod.SUPER, action = act.ResetFontSize },

  -- misc / useful
  { key = 'F1', mods = 'NONE', action = 'ActivateCopyMode' },
  { key = 'F2', mods = 'NONE', action = act.ActivateCommandPalette },
  { key = 'F3', mods = 'NONE', action = act.ShowLauncher },
  { key = 'F11', mods = 'NONE', action = act.ToggleFullScreen },
  { key = 'F12', mods = 'NONE', action = act.ShowDebugOverlay },
  { key = 'f',   mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = '' }) },
}

bind.mouse = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  }
}

-- modal pane-resize table activated by LEADER r (see keys above)
bind.key_tables = {
  resize_pane = {
    { key = LEFT,  action = act.AdjustPaneSize({ 'Left', 3 }) },
    { key = DOWN,  action = act.AdjustPaneSize({ 'Down', 3 }) },
    { key = UP,    action = act.AdjustPaneSize({ 'Up', 3 }) },
    { key = RIGHT, action = act.AdjustPaneSize({ 'Right', 3 }) },
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'Enter',  action = 'PopKeyTable' },
  },
}

-- session save/restore keys, only wired up if the resurrect plugin loaded
if resurrect_ok then
  table.insert(bind.keys, {
    key = 'S',
    mods = 'LEADER',
    action = wezterm.action_callback(function(win, pane)
      resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
    end),
  })
  table.insert(bind.keys, {
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
  })
end

return {
  leader = bind.leader,
  keys = bind.keys,
  key_tables = bind.key_tables,
  mouse_bindings = bind.mouse,
}
