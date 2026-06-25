# -*-mode:powershell-*- vim:ft=powershell

# =============================================================================
# PowerShell functions sourced by `$profile`.
# Date/time helpers mirroring the Unix `datetime` sh plugin so the same command
# names work across bash, zsh and PowerShell. PowerShell aliases cannot take
# arguments, so each of these is a function rather than a Set-Alias.

# Gets local date and time in ISO-8601 format `YYYY-MM-DDThh:mm:ss`.
function now { Get-Date -Format "yyyy-MM-ddTHH:mm:ss" }

# Gets UTC date and time in ISO-8601 format `YYYY-MM-DDThh:mm:ss`.
function unow { (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss") }

# Gets local date in `YYYY-MM-DD` format.
function nowdate { Get-Date -Format "yyyy-MM-dd" }

# Gets UTC date in `YYYY-MM-DD` format.
function unowdate { (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd") }

# Gets local time in `hh:mm:ss` format.
function nowtime { Get-Date -Format "HH:mm:ss" }

# Gets UTC time in `hh:mm:ss` format.
function unowtime { (Get-Date).ToUniversalTime().ToString("HH:mm:ss") }

# Gets Unix time stamp (seconds since epoch, UTC).
function tstamp { [System.DateTimeOffset]::UtcNow.ToUnixTimeSeconds() }

# Gets week number in ISO-8601 format `YYYY-Www`.
# System.Globalization.ISOWeek is available on .NET Framework 4.8 (PowerShell
# 5.1 on modern Windows) and .NET Core (PowerShell 7+).
function week {
    $d = Get-Date
    '{0}-W{1:D2}' -f [System.Globalization.ISOWeek]::GetYear($d), `
        [System.Globalization.ISOWeek]::GetWeekOfYear($d)
}

# Gets ISO-8601 weekday number (Monday = 1 .. Sunday = 7).
function weekday {
    $dow = [int](Get-Date).DayOfWeek   # .NET: Sunday = 0 .. Saturday = 6
    if ($dow -eq 0) { 7 } else { $dow }
}
