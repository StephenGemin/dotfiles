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
        # Default path if Chezmoi is not installed
        Set-Location -Path "$HOME/.local/share/chezmoi"
    }
}

# Navigates to Powershell's profile location.
function psconf {
    # Navigate to the directory containing the PowerShell profile
    Set-Location -Path (Split-Path -Path $PROFILE)
}
