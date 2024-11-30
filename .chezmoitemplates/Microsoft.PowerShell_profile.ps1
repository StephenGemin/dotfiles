# -*-mode:powershell-*- vim:ft=powershell

# ~/.config/powershell/profile.ps1
# =============================================================================
# Executed when PowerShell starts.
#
# On Windows, this file will be copied over to these locations after
# running `chezmoi apply` by the script `../../run_powershell.bat.tmpl`:
#     - %USERPROFILE%\Documents\PowerShell
#     - %USERPROFILE%\Documents\WindowsPowerShell
#
# See https://docs.microsoft.com/en/powershell/module/microsoft.powershell.core/about/about_profiles

# $ColorInfo = "DarkYellow"
# $ColorWarn = "DarkRed"

# Aliases 
# -----------------------------------------------------------------------------

# Use "d" to be consistent with my zsh setup on Windows see .zshrc
# due to alias conflict between zinit and zoxide for zsh on Windows
# I also find it easier to hit d vs. z
function cd {param ([string]$Path = ''); d $Path}
# cd- alias set in dot sourced modules
Set-Alias -Name "d-" -Value 'cd-'

# Terminal Styling
# -----------------------------------------------------------------------------

# https://learn.microsoft.com/en-au/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.4#psstyle
if ($PSVersionTable.PSVersion.Major -ge 7) {
  $PSStyle.FileInfo.Directory = $PSStyle.Foreground.Blue
  $PSStyle.FileInfo.Executable = "$($PSStyle.Foreground.Red)$($PSStyle.Formatting.Bold)"
}

oh-my-posh init pwsh --config "$env:USERPROFILE\.config\ohmyposh\zen.toml"| Invoke-Expression

# Plugins & Extra customizations
# -----------------------------------------------------------------------------
# Determine user profile parent directory.
$ProfilePath=Split-Path -parent $profile

$LocalPlugins = @(
    "core.ps1",
    "git.ps1",
    "file_navigation.ps1",
    "file_management.ps1"
)
foreach ($plugin in $LocalPlugins) {
    $PluginPath = Join-Path -Path $ProfilePath -ChildPath "$plugin"
    if (Test-Path $PluginPath) {
      . $PluginPath
    } else {
      Write-Warning "Plugin not found: $PluginPath"        
    }
}

# configure fzf wrapper for powershell
try {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
} catch {
    Write-Host "PSFzf module is not installed. Installing PSFzf..."
    Install-Module -Name PSFzf -Force
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# keep this at the end of file per zoxide docs
Invoke-Expression (& { (zoxide init --cmd d powershell | Out-String) })
