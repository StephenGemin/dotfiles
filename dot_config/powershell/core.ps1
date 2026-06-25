# -*-mode:powershell-*- vim:ft=powershell

# =============================================================================
# PowerShell functions sourced by `$profile`.

Set-Alias -Name "cl" -Value Clear-Host -Description "Clears screen."
# NeoVim seems buggy on Windows. Sometimes it just won't open a file, typically after tree-sitter syntax plugins have been installed.
# So, allow use of nvim vs. vim
# Set-Alias -Name "vim" -Value 'nvim'
function cdappd { cd $env:APPDATA }
function cdlappd { cd $env:LOCALAPPDATA }

# Reloads the shell by launching a fresh instance in place (akin to `exec $SHELL`).
function reload {
    $shellPath = (Get-Process -Id $PID).Path
    & $shellPath
    exit
}

# Prints each PATH entry on its own line.
function path { $env:PATH -split [System.IO.Path]::PathSeparator }

# Gets the primary local IPv4 address.
function localip {
    Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object { $_.IPAddress -ne '127.0.0.1' -and $_.PrefixOrigin -ne 'WellKnown' } |
        Select-Object -First 1 -ExpandProperty IPAddress
}