$ErrorActionPreference = 'Stop'
$exe = Join-Path $PSScriptRoot 'ov.exe'
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\ov.exe'
if (Test-Path $key) {
    $existing = (Get-Item $key).GetValue('')
    if ($existing -and $existing -ne $exe) { throw "ov.exe is already registered to $existing" }
}
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path $compiler)) { $compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe' }
& $compiler /nologo /target:exe /optimize+ ("/out:" + $exe) (Join-Path $PSScriptRoot 'Launcher.cs')
if ($LASTEXITCODE -ne 0) { throw 'Launcher compilation failed.' }
New-Item -Path $key -Force | Out-Null
Set-Item -Path $key -Value $exe
Write-Host "Registered: $exe"
Write-Host 'Try ov . in the Explorer address bar. Use ov --check . in a terminal to inspect the resolved folder.'
