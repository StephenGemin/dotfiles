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
        { label = 'Zsh', args = { 'zsh' } },
        { label = 'Bash', args = { 'bash' } },
    }
end

return {
    default_prog = default_prog,
    launch_menu = launch_menu
}
