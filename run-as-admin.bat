@echo off
REM run-as-admin.bat
REM Run this script as Administrator to setup Windows Terminal symlinks

echo ========================================
echo Windows Terminal Settings Setup
echo ========================================
echo.

REM Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script requires Administrator privileges.
    echo Please right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo [OK] Running with Administrator privileges
echo.

REM Get the current user's username
set "USERNAME=%USERNAME%"
echo Detected Windows username: %USERNAME%
echo.

REM Define paths
set "TERMINAL_DIR=%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
set "TARGET=%TERMINAL_DIR%\settings.json"

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"
set "SOURCE=%SCRIPT_DIR%settings.json"

echo Script directory: %SCRIPT_DIR%
echo Source file: %SOURCE%
echo Target location: %TARGET%
echo.

REM Check if source file exists
if not exist "%SOURCE%" (
    echo [ERROR] Source file not found: %SOURCE%
    echo Please make sure settings.json exists in your dotfiles directory
    pause
    exit /b 1
)

REM Check if Windows Terminal directory exists
if not exist "%TERMINAL_DIR%" (
    echo [ERROR] Windows Terminal directory not found: %TERMINAL_DIR%
    echo Please make sure Windows Terminal is installed
    pause
    exit /b 1
)

REM Backup existing settings.json if it exists and is not a symlink
if exist "%TARGET%" (
    fsutil reparsepoint query "%TARGET%" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [INFO] Existing symlink found, removing it...
        del "%TARGET%"
    ) else (
        echo [INFO] Backing up existing settings.json...
        move "%TARGET%" "%TARGET%.backup"
        echo [OK] Backup created: %TARGET%.backup
    )
)

REM Create the symlink
echo.
echo Creating symlink...
mklink "%TARGET%" "%SOURCE%"

if %errorLevel% equ 0 (
    echo.
    echo ========================================
    echo [SUCCESS] Windows Terminal settings.json symlink created!
    echo ========================================
    echo.
    echo Your Windows Terminal settings are now synced to:
    echo %SOURCE%
    echo.
    echo Any changes to the file in your dotfiles will be reflected in Windows Terminal.
) else (
    echo.
    echo [ERROR] Failed to create symlink
    echo Please make sure:
    echo   1. You're running as Administrator
    echo   2. The source file exists
    echo   3. No other process is using the target file
)

echo.
pause
