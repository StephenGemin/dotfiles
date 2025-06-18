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

# PATH
# -----------------------------------------------------------------------------

# Update PATH to point to msys64 dependencies
# i.e. make, gcc, mingw64, etc for neovim and it's plugins
$env:Path += ";C:\msys64\usr\bin;C:\msys64\mingw64"

# Environment vars
$env:ZOXIDE_KEY = "s"

# Aliases
# -----------------------------------------------------------------------------
# Remove built-in powershell aliases that conflict with my aliases
Remove-Item alias:\gc -Force
Remove-Item alias:\gl -Force

# Use "d" to be consistent with my zsh setup on Windows see .zshrc
# due to alias conflict between zinit and zoxide for zsh on Windows
# I also find it easier to hit d vs. z
function cd {param ([string]$Path = ''); d $Path}
# cd- alias set in dot sourced modules
Set-Alias -Name ("$($env:ZOXIDE_KEY)-") -Value 'cd-'

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
    "tool_configs.ps1",
    "file_navigation.ps1",
    "file_management.ps1",
    "git.ps1",
    "core.ps1"
)
foreach ($plugin in $LocalPlugins) {
    $PluginPath = Join-Path -Path $ProfilePath -ChildPath "$plugin"
    if (Test-Path $PluginPath) {
      . $PluginPath
    } else {
      Write-Warning "Plugin not found: $PluginPath"
    }
}

# Load custom code from separate configuration file
# -----------------------------------------------------------------------------
$LocalExtras = $(Join-Path -Path $ProfilePath -ChildPath ".pwsh_extras.ps1")
if (Test-Path $LocalExtras) {
    . $LocalExtras
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
Invoke-Expression (& { (zoxide init --cmd $env:ZOXIDE_KEY powershell | Out-String) })
