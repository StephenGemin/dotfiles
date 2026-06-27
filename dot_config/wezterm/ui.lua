local wezterm = require('wezterm')

-- Tab-title and status-bar event handlers. Required for its side effects from
-- wezterm.lua; the events fire for the lifetime of the GUI.

-- Resolve a few accent colors from whichever builtin scheme is active so the
-- tab bar / status bar track the light<->dark switch handled in wezterm.lua.
local schemes = wezterm.color.get_builtin_schemes()

local function palette(scheme_name)
  local s = schemes[scheme_name] or {}
  local ansi = s.ansi or {}
  local brights = s.brights or {}
  return {
    bg = s.background or '#24273a',
    fg = s.foreground or '#cad3f5',
    accent = ansi[5] or '#8aadf4', -- blue
    subtle = brights[1] or '#5b6078',
    green = ansi[3] or '#a6da95',
  }
end

-- Tab titles: "<index>: <title>" with a zoom marker; active tab highlighted.
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local c = palette(config.color_scheme)
  local title = tab.active_pane.title
  if not title or title == '' then
    title = 'shell'
  end
  local zoom = tab.active_pane.is_zoomed and ' [Z]' or ''
  local label = ' ' .. (tab.tab_index + 1) .. ': ' .. title .. zoom .. ' '
  if wezterm.column_width(label) > max_width then
    label = ' ' .. wezterm.truncate_right(label, max_width - 2) .. ' '
  end
  local bg = tab.is_active and c.accent or c.bg
  local fg = tab.is_active and c.bg or c.fg
  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = label },
  }
end)

-- Right status: leader indicator, active workspace, date/time.
wezterm.on('update-status', function(window, pane)
  local c = palette(window:effective_config().color_scheme)
  local cells = {}

  if window:leader_is_active() then
    table.insert(cells, { Foreground = { Color = c.bg } })
    table.insert(cells, { Background = { Color = c.green } })
    table.insert(cells, { Attribute = { Intensity = 'Bold' } })
    table.insert(cells, { Text = ' LEADER ' })
    table.insert(cells, 'ResetAttributes')
  end

  table.insert(cells, { Foreground = { Color = c.accent } })
  table.insert(cells, { Text = '  ' .. window:active_workspace() .. ' ' })

  table.insert(cells, { Foreground = { Color = c.fg } })
  table.insert(cells, { Text = wezterm.strftime('  %a %b %d  %H:%M ') })

  window:set_right_status(wezterm.format(cells))
end)

return {}
