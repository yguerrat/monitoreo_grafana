@echo off
REM Activa Jenkins opcional desde la carpeta del kit y abre su página.
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0iniciar-jenkins.ps1"
if errorlevel 1 (
  echo Revisa el error anterior.
) else (
  start "" "http://localhost:8080"
)
pause
