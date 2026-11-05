$ErrorActionPreference = 'Stop'
$exe = Join-Path $PSScriptRoot 'ov.exe'
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\ov.exe'
if ((Test-Path $key) -and ((Get-Item $key).GetValue('') -eq $exe)) {
    Remove-Item -LiteralPath $key
}
if (Test-Path -LiteralPath $exe) { Remove-Item -LiteralPath $exe }
Write-Host 'Removed executable entry point. The original ov.cmd and PATH setup remain available.'
