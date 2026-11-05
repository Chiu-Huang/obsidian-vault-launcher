@echo off
setlocal
set "OV_TARGET=%CD%"
if not "%~1"=="" set "OV_TARGET=%~f1"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0ov-core.ps1" -Folder "%OV_TARGET%"
exit /b %ERRORLEVEL%
