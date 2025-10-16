<#
First, let's get real. Make PowerShell act more like a grown up
programming language with its parsing and error handling.
#>
Set-StrictMode -Version 3.0

<#
Second, sane behaviors for any errors. It's weird that the default 
is to keep going.
#>
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

# Reload user profile for current machine
function rlp {
  . $PROFILE.CurrentUserCurrentHost
  Write-Host "Profile Reloaded"
}

# Add a path only once to $Env:Path
function addPath {
  param ( $path ) 

  if ( -Not ($Env:Path -split ";" -contains $path) ) {
    $Env:Path += ";${path}"
  }
}

# Add a path only once to $Env:PSModulePath
function addModulePath {
  param ( $modulePath ) 

  if ( -Not ($Env:PSModulePath -split ";" -contains $modulePath) ) {
    $Env:PSModulePath += ";${modulePath}"
  }
}

# Pretty Print the Path environment variable while preserving ordering
function ppp { Write-PrettyPaths($Env:Path) }

# Pretty Print the PSModulePath environment variable while preserving ordering
function ppmp { Write-PrettyPaths($Env:PSModulePath) }

# Path Pretty Printer
function Write-PrettyPaths {
  param( $pathBlob )
  $Private:conColor1  = [System.ConsoleColor]::Gray
  $Private:conColor2  = [System.ConsoleColor]::DarkGreen
  $Private:fgc        = [System.ConsoleColor]::Black
  $Private:bgc        = $conColor1
#  $Private:bullet     = [char]0x2022
#  $Private:hole       = $bullet
  $Private:paths      = $pathBlob -split ";"
  $Private:maxPathLen = ($paths | Measure-Object -Maximum -Property Length).Maximum

  foreach ($path in $paths) {
    $padPath   = $path.PadRight($maxPathLen, " ")
    Write-Host "${padPath}" -ForegroundColor $fgc -BackgroundColor $bgc
#    Write-Host "${hole}  ${padPath}  ${hole}" -ForegroundColor $fgc -BackgroundColor $bgc

    # Mabye flip some values for next iteration
    $bgc     = if ( $bgc -eq $conColor1 ) { $conColor2 } else { $conColor1 }
#    $hole    = if ( $hole -eq ' ' ) { $bullet } else { ' ' }
  }
}

# Show profile file paths
function profiles {
  $Private:profilePaths = [Ordered]@{
    CurrentUserCurrentHost = "$($PROFILE.CurrentUserCurrentHost)"
    CurrentUserAllHosts    = "$($PROFILE.CurrentUserAllHosts)"
    AllUsersCurrentHost    = "$($PROFILE.AllUsersCurrentHost)"
    AllUsersAllHosts       = "$($PROFILE.AllUsersAllHosts)"
  }
  
  $profilePaths.GetEnumerator() | ForEach-Object {
    Write-Host "`r`n$($_.Name)" -ForegroundColor Cyan
    Write-Host "$('-' * 80)"    -ForegroundColor Cyan
    Write-Host $_.Value         -ForegroundColor Yellow
  }

  Write-Host "" # Empty line
}

# Show ConsoleColor Combinations.
function showColors {
  # See some ConsoleColor info: [Enum]::GetValues([System.ConsoleColor]) | % { write "${_} -> $($_.GetType().Name)" }
  $Private:consoleColors      = [Enum]::GetValues([System.ConsoleColor])
  $Private:darkConsoleColors  = $consoleColors[0..7]
  $Private:lightConsoleColors = $consoleColors[8..15]
 
  # Find longest color name.
  $Private:maxLen = 0
  foreach ($c in $consoleColors) {
    $Private:cLen = $c.ToString().Length
    if ($cLen -gt $maxLen) { $maxLen = $cLen }
  }

  $Private:cellWidth = $maxLen + 2

  $centerSemiCalc = {
    param ( $value )
    [int]$Private:result = [Math]::Ceiling([Math]::Truncate($value / 2))
    $result
  }

  $centerCalc = {
    param ( $cellWidth, $textLength )
    $Private:lPad = ( & $centerSemiCalc -value $cellWidth ) - ( & $centerSemiCalc -value $textLength )
    $lPad
  }

  # Iterate background colors to build and print grid header
  $writeGridHeader = {
    param ( $cellWidth, $colors )
    $Private:blackCC      = [System.ConsoleColor]::Black
    $Private:whiteCC      = [System.ConsoleColor]::White
    $Private:needsWhiteBG = @( $blackCC, [System.ConsoleColor]::DarkGray )
    
    foreach ($fgc in $colors) {
      $Private:bgc     = if ($needsWhiteBG -contains $fgc) { $whiteCC } else { $blackCC }
      $Private:fgcName = $fgc.ToString()
      $Private:fgcLen  = $fgcName.Length
      $Private:lPad    = " " * ( & $centerCalc -cellWidth $cellWidth -textLength $fgcLen )
      $Private:cellVal = "${lPad}${fgcName}".PadRight($cellWidth, " ")
      Write-Host $cellVal -ForegroundColor $fgc -BackgroundColor $bgc -NoNewLine
    }
    Write-Host "" # Add CRLF to header line
  }

  # Iterate foreground colors over background colors
  $writeGridLines = {
    param ( $cellWidth, $colors, $consoleColors )
    foreach ($fgc in $consoleColors) {
      foreach ($bgc in $colors) {
        $Private:fgcName = $fgc.ToString()
        $Private:fgcLen  = $fgcName.Length
        $Private:lPad    = " " * ( & $centerCalc -cellWidth $cellWidth -textLength $fgcLen )
        $Private:cellVal = "${lPad}${fgcName}".PadRight($cellWidth, " ")
        Write-Host $cellVal -ForegroundColor $fgc -BackgroundColor $bgc -NoNewLine 
      }
      Write-Host "" # Add CRLF to current line
    }
  }

  & $writeGridHeader -cellWidth $cellWidth -colors $darkConsoleColors
  & $writeGridLines  -cellWidth $cellWidth -colors $darkConsoleColors  -consoleColors $consoleColors
  Write-Host "" # Blank line
  & $writeGridHeader -cellWidth $cellWidth -colors $lightConsoleColors
  & $writeGridLines  -cellWidth $cellWidth -colors $lightConsoleColors -consoleColors $consoleColors
}

<#
Add Advantage PowerShell tooling script folder to both
$Env:Path and $Env:PSModulePath if not already added.
#>
$Private:scriptFolderPath = "C:\Development\Advantage\advantage-scripts\Powershell"
addPath $scriptFolderPath
addModulePath $scriptFolderPath

# Add SQL Management Studio to path
$Private:ssmsPath = "C:\Program Files (x86)\Microsoft SQL Server Management Studio 20\Common7\IDE"
addPath $ssmsPath

# Starship
Invoke-Expression (&starship init powershell)

# Coverlet report tooling
#Import-Module CoverletReport -Verbose -Force
Import-Module CoverletReport -Force
