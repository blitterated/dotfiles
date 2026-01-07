# Powershell 5 & 7.5 $PROFILE.CurrentUserCurrentHost filename
$ps_cfgname       = "Microsoft.PowerShell_profile.ps1"

# Powershell 5 $PROFILE.CurrentUserCurrentHost config directory and full file path
$ps5_cfgdir       = "C:\Users\peteyoung\Documents\WindowsPowerShell"
$ps5_cfgpath      = "${ps5_cfgdir}\${ps_cfgname}"

# Powershell 7.5 $PROFILE.CurrentUserCurrentHost config directory and full file path
$ps7_cfgdir       = "C:\Users\peteyoung\Documents\PowerShell"
$ps7_cfgpath      = "${ps7_cfgdir}\${ps_cfgname}"

# dotfile repo directory path
$dotFileDirPath   = "${HOME}\.dotfiles"

# dotfile repo Windows directory path
$dotFileWinPath   = "${dotFileDirPath}\Windows"

# Powershell 5 & 7.5 config file in dotfile repo
$ps_shared_config = "${dotFileWinPath}\PowerShell\${ps_cfgname}"

# Windows Terminal config filename
$winterm_config = "${HOME}\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

function Remove-Config {
  param ( $configFileName )

  if ( Test-Path -Path "${configFileName}" ) {
    Remove-Item -Path "${configFileName}" -Force
  }
}

function Clean-ConfigFiles {
  param ( $configFiles )

  foreach ($cf in $configFiles) {
    Remove-Config "${cf}"
  }
}

Clean-ConfigFiles "${ps5_cfgpath}", "${ps7_cfgpath}"

# TODO: Pull from dotfile repo
# Create symbolic links to the dotfile repo for PS 5 & 7.5
# You MUST be ADMIN to create links!
New-Item -ItemType SymbolicLink -Path "${ps5_cfgpath}" -Target "${ps_shared_config}"
New-Item -ItemType SymbolicLink -Path "${ps7_cfgpath}" -Target "${ps_shared_config}"
