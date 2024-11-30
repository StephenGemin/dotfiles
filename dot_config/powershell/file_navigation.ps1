# -*-mode:powershell-*- vim:ft=powershell

# =============================================================================
# PowerShell functions sourced by `$profile`.
# aliases are defined at bottom of file

# functions
# -----------------------------------------------------------------------------

function Get-ChildItemSimple {
    <#
    .SYNOPSIS
        Lists visible files in wide format.
    .PARAMETER Path
        The directory to list from.
    .INPUTS
        System.String[]
    .OUTPUTS
        System.IO.FileInfo
        System.IO.DirectoryInfo
    .LINK
        Get-ChildItem
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$true
        )]
        [string[]]$Path = ".",

        [Parameter(ValueFromRemainingArguments=$true)]
        $Params
    )

    begin {
        # https://stackoverflow.com/a/33302472
        $hashtable = @{}
        if ($Params) {
            $Params | ForEach-Object {
                if ($_ -match "^-") {
                    $hashtable.$($_ -replace "^-") = $null
                }
                else {
                    $hashtable.$(([string[]]$hashtable.Keys)[-1]) = $_
                }
            }
        }
    }

    process {
        Get-ChildItem -Path @Path @hashtable | Format-Wide
    }
}

function Get-ChildItemAll {
    <#
    .SYNOPSIS
        Lists all files in long format, excluding `.` and `..`.
    .PARAMETER Path
        The directory to list from.
    .INPUTS
        System.String[]
    .OUTPUTS
        System.IO.FileInfo
        System.IO.DirectoryInfo
    .LINK
        Get-ChildItem
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$true
        )]
        [string[]]$Path = ".",

        [Parameter(ValueFromRemainingArguments=$true)]
        $Params
    )

    begin {
        # https://stackoverflow.com/a/33302472
        $hashtable = @{}
        if ($Params) {
            $Params | ForEach-Object {
                if ($_ -match "^-") {
                    $hashtable.$($_ -replace "^-") = $null
                }
                else {
                    $hashtable.$(([string[]]$hashtable.Keys)[-1]) = $_
                }
            }
        }
    }

    process {
        Get-ChildItem -Path @Path -Force @hashtable
    }
}

function Set-LocationLast {
    <#
    .SYNOPSIS
        Goes to last used directory.
    .INPUTS
        System.String
    .OUTPUTS
        None
    .LINK
        Set-Location
    #>
    param()

    process {
        try {
            # Attempt to navigate forward
            Set-Location "+"
            Write-Verbose "Navigated forward. Current path: $(Get-Location)"
        } catch {
            # If forward navigation fails, fallback to backward navigation
            try {
                Set-Location "-"
                Write-Verbose "Navigated backward. Current path: $(Get-Location)"
            } catch {
                Write-Warning "No forward or backward navigation available."
            }
        }
    }
}

function Set-LocationUp {
    <#
    .SYNOPSIS
        Navigates up a specified number of directory levels.
    .DESCRIPTION
        This function moves up a specified number of parent directories, defaulting to one level if no input is provided.
    .PARAMETER Levels
        The number of directory levels to move up.
    .INPUTS
        System.Int32
    .OUTPUTS
        None
    .LINK
        Set-Location
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Low'
    )]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Levels = 1
    )

    begin {
        # Construct the path to go up the specified levels
        $path = (".." + ("\.." * ($Levels - 1)))
        $resolvedPath = Convert-Path -Path $path
        Write-Verbose "Destination set to $resolvedPath"
    }

    process {
        if ($PSCmdlet.ShouldProcess($resolvedPath, 'Change directory')) {
            Write-Verbose "Navigating to $resolvedPath"
            Set-Location $resolvedPath
        }
    }
}
function dest{
    $variableValue = Get-Variable "LocationHistoryForward" -Scope "Global" -ValueOnly
    Write-Output "Destination will be $variableValue"
}
# function Set-LocationUp1{ Set-LocationUp -Levels 1 }
function Set-LocationUp2{ Set-LocationUp -Levels 2 }
function Set-LocationUp3{ Set-LocationUp -Levels 3 }
function Set-LocationUp4{ Set-LocationUp -Levels 4 }
function Set-LocationUp5{ Set-LocationUp -Levels 5 }

# aliases
# -----------------------------------------------------------------------------

if (!(Get-Command "ls" -ErrorAction "Ignore")) {
    Set-Alias -Name "ls" -Value Get-ChildItemSimple -Description "Lists visible files in wide format."
}
Set-Alias -Name "l" -Value Get-ChildItemAll -Description "Lists visible files in long format."
Set-Alias -Name "la" -Value Get-ChildItemAll -Description "Lists all files in long format."

Set-Alias -Name "cd-" -Value Set-LocationLast -Description "Goes to last used directory."
Set-Alias -Name ".." -Value Set-LocationUp -Description "cd up 1 directory."
Set-Alias -Name "..." -Value Set-LocationUp2 -Description "cd up 2 directories."
Set-Alias -Name "..3" -Value Set-LocationUp3 -Description "cd up 3 directories."
Set-Alias -Name "..4" -Value Set-LocationUp4 -Description "cd up 4 directories."
Set-Alias -Name "..5" -Value Set-LocationUp5 -Description "cd up 5 directories."
