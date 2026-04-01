@echo off
title DriveAI Factory Dashboard
cd /d "C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen"

echo ========================================
echo   DriveAI Factory - Starting Services
echo ========================================
echo.

:: Start Python Assistant Server (Port 3002) in eigenem Fenster
echo [1/2] Starting Assistant Server (Port 3002)...
start "DriveAI Assistant Server" cmd /k "cd /d C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen && python -m factory.hq.assistant.server"

:: Wait for server to be ready
echo Warte 5 Sekunden auf Server...
timeout /t 5 /nobreak > nul

:: Start Dashboard (Port 3000 + 3001) in eigenem Fenster
echo [2/2] Starting Dashboard (Port 3000 + 3001)...
start "DriveAI Dashboard" cmd /k "cd /d C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen\factory\hq\dashboard && npm start"

echo.
echo ========================================
echo   Services gestartet:
echo   - Assistant Server: http://localhost:3002
echo   - Dashboard:        http://localhost:3000
echo ========================================
echo.
echo Dieses Fenster kann geschlossen werden.
echo Druecke eine Taste zum Schliessen...
pause > nul
