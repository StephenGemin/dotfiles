local wezterm = require('wezterm')

local act = wezterm.action
local target_triple = wezterm.target_triple

local mod = {}
local bind = {}

if target_triple:find("darwin") then
   mod.SUPER = 'SUPER'
else
   mod.SUPER = 'CTRL' -- to not conflict with Windows key shortcuts
end

-- https://github.com/mrjones2014/smart-splits.nvim
-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == 'true'
end

local direction_keys = {
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
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

  -- tabs
  { key = 't', mods = 'LEADER', action = act.SpawnTab('DefaultDomain') },
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

  -- panes
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane({ confirm = false }) },
  { key = 'Enter', mods = mod.SUPER, action = act.TogglePaneZoomState },
  { key = "PageUp", mods = '', action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = '', action = act.ScrollByPage(1) },

  -- panes: splitting
  { key = 'j', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'l', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  -- panes: naviation
  -- move between split panes
  split_nav('move', 'h'),
  split_nav('move', 'j'),
  split_nav('move', 'k'),
  split_nav('move', 'l'),
  -- panes: resize
  split_nav('resize', 'h'),
  split_nav('resize', 'j'),
  split_nav('resize', 'k'),
  split_nav('resize', 'l'),

  {
    key = 'p',
    mods = 'CTRL|ALT',
    action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
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

return {
  leader = bind.leader,
  keys = bind.keys,
  mouse_bindings = bind.mouse,
}
