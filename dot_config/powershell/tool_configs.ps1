# -*-mode:powershell-*- vim:ft=powershell

# =============================================================================
# PowerShell functions sourced by `$profile`.

# functions
# -----------------------------------------------------------------------------

# Navigates to Chezmoi's local repo.
function chezmoiconf {
    if (Get-Command -Name chezmoi -ErrorAction SilentlyContinue) {
        Set-Location -Path $(chezmoi source-path)
    } else {
        Set-Location -Path (Join-Path -Path (Join-Path -Path (Join-Path -Path $HOME -ChildPath ".local") -ChildPath "share") -ChildPath "chezmoi")
    }
}

# Navigates to Powershell's profile location.
function psconf {
    Set-Location -Path (Split-Path -Path $PROFILE)
}

# Navigates to neovim config
function nvimconf {
    Set-Location -Path (Join-Path -Path $env:LOCALAPPDATA -ChildPath "nvim")
}
