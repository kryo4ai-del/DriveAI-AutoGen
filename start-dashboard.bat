@echo off
title DriveAI Factory Dashboard
cd /d "C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen"

echo ========================================
echo   DriveAI Factory - Starting Services
echo ========================================
echo.

:: Start Python Assistant Server (Port 3002)
echo [1/2] Starting Assistant Server (Port 3002)...
start /B "" python -m factory.hq.assistant.server > nul 2>&1

:: Wait for server to be ready
timeout /t 3 /nobreak > nul

:: Start Dashboard (Port 3000 + 3001)
echo [2/2] Starting Dashboard (Port 3000 + 3001)...
cd factory\hq\dashboard
npm start
