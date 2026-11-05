$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'install-exe.ps1')
& (Join-Path $PSScriptRoot 'install-path.ps1')
Write-Host 'Installation complete. Keep this folder in place. Open a new terminal for ov .; Explorer uses the App Paths registration immediately.'
