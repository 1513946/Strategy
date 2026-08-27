param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Blue', 'Yellow')]
    [string]$Team
)

$ErrorActionPreference = 'Stop'

$projectDir = Join-Path $PSScriptRoot "..\src\Strategy4$Team"
$dll = Get-ChildItem -Path $projectDir -Recurse -Filter "Strategy4$Team.dll" -File |
    Where-Object { $_.FullName -match '\\(Release|Debug)\\' } |
    Sort-Object LastWriteTimeUtc -Descending |
    Select-Object -First 1

if (-not $dll) {
    throw "No build output found for Strategy4$Team.dll. Build the project first."
}

$dest = Join-Path (Split-Path $PSScriptRoot -Parent) "Strategy4$Team.dll"
Copy-Item -LiteralPath $dll.FullName -Destination $dest -Force
Write-Host "Deployed: $($dll.FullName) -> $dest"
