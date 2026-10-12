@echo off
rem Startar installera.ps1 for Donkeystories. Dubbelklicka for att kora.
rem Provkorning (andrar ingenting): installera.cmd -Provkorning
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0installera.ps1" %*
echo.
pause
