@echo off
setlocal
title OpenCode + Ollama Setup

echo ==========================================================
echo Starting OpenCode and Ollama Cloud Setup...
echo ==========================================================
echo.

:: Run the PowerShell script with ExecutionPolicy Bypass so it executes cleanly
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_opencode_ollama.ps1" %*

if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] The setup script encountered an error (exit code: %ERRORLEVEL%).
)

echo.
echo Press any key to exit...
pause >nul
endlocal
