param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Blue', 'Yellow')]
    [string]$Team,

    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vsPath) {
    throw 'Visual Studio with C++ tools was not found.'
}

$msbuild = Join-Path $vsPath 'MSBuild\Current\Bin\MSBuild.exe'
$project = Join-Path $PSScriptRoot "..\src\Strategy4$Team\Strategy4$Team.vcxproj"

& $msbuild $project `
    "/p:Configuration=$Configuration" `
    '/p:Platform=Win32' `
    '/p:PlatformToolset=v145' `
    '/m' `
    '/v:minimal'

exit $LASTEXITCODE
