# -*-mode:powershell-*- vim:ft=powershell

# =============================================================================
# PowerShell functions sourced by `$profile`.

Set-Alias -Name "cl" -Value Clear-Host -Description "Clears screen."
# NeoVim seems buggy on Windows. Sometimes it just won't open a file, typically after tree-sitter syntax plugins have been installed.
# So, allow use of nvim vs. vim
# Set-Alias -Name "vim" -Value 'nvim'
function cdappd { cd $env:APPDATA }
function cdlappd { cd $env:LOCALAPPDATA }