﻿$ErrorActionPreference = 'Stop'
$toolsPath = (Split-Path -Parent $MyInvocation.MyCommand.Definition)
. "$toolsPath\helpers.ps1"

$pp = Get-PackageParameters

$parameters += if ($pp.NoDesktopShortcut)     { " /desktopshortcut 0"; Write-Host "Desktop shortcut won't be created" }
$parameters += if ($pp.NoTaskbarShortcut)     { " /pintotaskbar 0"; Write-Host "Opera won't be pinned to taskbar" }

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'exe'
  url            = 'https://get.geo.opera.com/pub/opera-developer/67.0.3523.0/win/Opera_Developer_67.0.3523.0_Setup.exe'
  url64          = 'https://get.geo.opera.com/pub/opera-developer/67.0.3523.0/win/Opera_Developer_67.0.3523.0_Setup_x64.exe'
  checksum       = '69e5e6c29f31fb307b3db496e6e8369cad5420759906951de68adfe4ee957b86'
  checksum64     = '943b5ab781627d10a619cf1e23c11209193131b1853c25de6125f67b83b6294b'
  checksumType   = 'sha256'
  checksumType64 = 'sha256'
  silentArgs     = '/install /silent /launchopera 0 /setdefaultbrowser 0' + $parameters
  validExitCodes = @(0)
}

$version = '67.0.3523.0'
if (!$Env:ChocolateyForce -and (IsVersionAlreadyInstalled $version)) {
  Write-Output "Opera $version is already installed. Skipping download and installation."
} else {
  Install-ChocolateyPackage @packageArgs
}
