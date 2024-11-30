# -*-mode:powershell-*- vim:ft=powershell

# =============================================================================
# PowerShell functions sourced by `$profile`.
# aliases are defined at bottom of file

Set-Alias -Name "grep" Select-String

function New-ItemEmpty {
    <#
    .SYNOPSIS
        Creates an empty file or updates its timestamp.
    .Description
        Host-level *nix equivalent to `touch`.
    .INPUTS
        System.Object
    .OUTPUTS
        None
    .LINK
        New-Item
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true
        )]
        [string]$File
    )

    if (Test-Path $File) {
        (Get-ChildItem $File).LastWriteTime = Get-Date
    }
    else {
        New-Item -ItemType File $File
    }
}

if (!(Get-Command "touch" -ErrorAction "Ignore")) {
    Set-Alias -Name "touch" -Value New-ItemEmpty -Description "Creates an empty file or updates its timestamp."
}


function Find-Directory {
    <#
    .SYNOPSIS
        Finds directories.
    .INPUTS
        System.Object
    .OUTPUTS
        System.String
    .LINK
        Get-ChildItem
    #>
    Get-ChildItem -Path . -Directory -Name -Recurse -ErrorAction SilentlyContinue -Include @args
}

function Find-File {
    <#
    .SYNOPSIS
        Finds files.
    .INPUTS
        System.Object
    .OUTPUTS
        System.String
    .LINK
        Get-ChildItem
    #>
    Get-ChildItem -Path . -File -Name -Recurse -ErrorAction SilentlyContinue -Include @args
}

Set-Alias -Name "fd" -Value Find-Directory -Description "Finds directories."

Set-Alias -Name "ff" -Value Find-File -Description "Finds files."
