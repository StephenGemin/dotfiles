local wezterm = require('wezterm')

local default_prog = {}
local launch_menu = {}

if wezterm.target_triple:find("windows") then
    default_prog = { 'pwsh', '-NoLogo' }
    launch_menu = {
        { label = 'Pwsh', args = { 'pwsh', '-NoLogo' } },
        { label = 'PowerShell', args = { 'powershell' } },
        { label = 'Command Prompt', args = { 'cmd' } },
    }
else
    default_prog = { '/usr/bin/zsh' }
    launch_menu = {
        { label = 'Zsh', args = { 'zsh', '-l' } },
        { label = 'Bash', args = { 'bash', '-l' } },
    }
end

return {
    default_prog = default_prog,
    launch_menu = launch_menu
}
