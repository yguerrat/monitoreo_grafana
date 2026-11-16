@echo off
REM Abre el laboratorio desde su propia carpeta, aunque se haga doble clic desde otro lugar.
REM Llama al verificador y, si todo responde, abre la guía en el navegador.
setlocal
cd /d "%~dp0"
echo Iniciando el laboratorio desde: %CD%
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0iniciar-y-verificar.ps1"
echo.
if errorlevel 1 (
  echo Revisa el mensaje anterior y LEEME.txt.
) else (
  echo Todo listo. Abriendo la guia...
  start "" "%~dp0guia-monitoreo-interactiva.html"
)
pause
