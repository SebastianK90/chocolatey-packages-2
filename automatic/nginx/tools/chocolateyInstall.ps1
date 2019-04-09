﻿$toolsDir = Split-Path -parent $MyInvocation.MyCommand.Definition
. "$toolsDir\helpers.ps1"

$pp = Get-PackageParameters

$arguments = @{
    packageName = $env:chocolateyPackageName
    file        = "$toolsDir\nginx-1.15.11.zip"
    destination = if ($pp.installLocation) { $pp.installLocation } else { Get-ToolsLocation }
    port        = if ($pp.Port) { $pp.Port } else { 80 }
    serviceName = if ($pp.NoService) { $null } elseif ($pp.serviceName) { $pp.serviceName } else { 'nginx' }
}

if (-not (Assert-TcpPortIsOpen $arguments.port)) {
    throw 'Please specify a different port number...'
}

Install-Nginx $arguments
