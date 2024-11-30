# -*-mode:powershell-*- vim:ft=powershell

# =============================================================================
# PowerShell functions sourced by `$profile`.

Set-Alias -Name "cl" -Value Clear-Host -Description "Clears screen."
Set-Alias -Name "vim" -Value 'nvim'
function cdappd { cd $env:APPDATA }
function cdlappd { cd $env:LOCALAPPDATA }