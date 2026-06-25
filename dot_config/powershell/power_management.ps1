# -*-mode:powershell-*- vim:ft=powershell

# =============================================================================
# PowerShell functions sourced by `$profile`.
# Session/power helpers mirroring the Unix `power_management` sh plugin. These
# use the same underlying Windows commands as that plugin's Windows branch, so
# `lock` / `hibernate` / `reboot` / `poweroff` behave the same whether invoked
# from zsh-on-Windows or PowerShell. This profile is only applied on Windows
# (see .chezmoiignore), so no per-OS guard is needed here.

# Locks the session.
# The argument is quoted so PowerShell does not parse the comma as the array
# operator and split it into two separate arguments to rundll32.
function lock { rundll32.exe "user32.dll,LockWorkStation" }

# Hibernates the system.
function hibernate { shutdown.exe /h }

# Restarts the system.
function reboot { shutdown.exe /r }

# Shuts down the system.
function poweroff { shutdown.exe /s }
