﻿$ErrorActionPreference = 'Stop';
$PackageParameters = Get-PackageParameters

$toolsDir     = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

$url          = 'https://download5.veeam.com/VAW/v6/VeeamAgentWindows_6.0.0.960.zip'
$checksum     = '78efc40ea05bc407c9a4147d9afcba8e1ef54be8cae5496857b6bf169ed42813'
$checksumType = 'sha256'

Import-Module -Name "$($toolsDir)\helpers.ps1"

$zipArgs = @{
    packageName   = $env:ChocolateyPackageName
    url           = $url
    unzipLocation = $ENV:TMP
    checksum      = $checksum
    checksumType  = $checksumType
}

$packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    fileType       = 'EXE'
    file           = "$($ENV:TMP)\VeeamAgentWindows_$($packageVersion).exe"
    silentArgs     = '/silent /accepteula /acceptthirdpartylicenses'
    validExitCodes = @(0, 1000, 1101)
}

Install-ChocolateyZipPackage @zipArgs

Install-ChocolateyInstallPackage @packageArgs

if ($PackageParameters.NoAutostartHard) {
    Update-RegistryValue `
        -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" `
        -Name "Veeam.EndPoint.Tray.exe" `
        -Type Binary `
        -Value ([byte[]](0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)) `
        -Message "Disable Veeam Agent Autostart"
}
else {
    Update-RegistryValue `
        -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" `
        -Name "Veeam.EndPoint.Tray.exe" `
        -Type Binary `
        -Value ([byte[]](0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)) `
        -Message "Default Veeam Agent Autostart"
}

if ($PackageParameters.CleanStartmenu) {
    Remove-FileItem `
        -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Veeam\"
    Install-ChocolateyShortcut `
        -ShortcutFilePath "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Veeam Agent.lnk" `
        -TargetPath "C:\Program Files\Veeam\Endpoint Backup\Veeam.EndPoint.Tray.exe"
    Install-ChocolateyShortcut `
        -ShortcutFilePath "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Veeam File Level Restore.lnk" `
        -TargetPath "C:\Program Files\Veeam\Endpoint Backup\Veeam.EndPoint.FLR.exe"
}
