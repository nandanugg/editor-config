@echo off
REM Sync .wslconfig to Windows user directory using symlink
REM NOTE: This script requires Administrator privileges to create symlinks

echo.
echo ========================================
echo WSL Configuration Sync
echo ========================================
echo.

REM Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script requires Administrator privileges.
    echo Please right-click and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

REM Get the current directory (should be the WSL mount path like \\wsl$\...)
set "SOURCE_DIR=%~dp0"

REM Check if .wslconfig exists
if not exist "%SOURCE_DIR%.wslconfig" (
    echo ERROR: .wslconfig file not found in %SOURCE_DIR%
    echo.
    pause
    exit /b 1
)

REM Destination is the user's home directory
set "DEST_FILE=%USERPROFILE%\.wslconfig"
set "SOURCE_FILE=%SOURCE_DIR%.wslconfig"

echo Source: %SOURCE_FILE%
echo Destination: %DEST_FILE%
echo.

REM If destination is already a symlink pointing to source, skip
if exist "%DEST_FILE%" (
    fsutil reparsepoint query "%DEST_FILE%" >nul 2>&1
    if %errorlevel% equ 0 (
        echo Destination is already a symlink. Removing it...
        del "%DEST_FILE%"
    ) else (
        echo Backing up existing .wslconfig to %DEST_FILE%.backup
        move /Y "%DEST_FILE%" "%DEST_FILE%.backup" >nul
    )
)

REM Create symbolic link
echo Creating symbolic link...
mklink "%DEST_FILE%" "%SOURCE_FILE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCCESS: .wslconfig symlink created!
    echo ========================================
    echo.
    echo IMPORTANT: You need to restart WSL for changes to take effect.
    echo Run this command from PowerShell or CMD:
    echo     wsl --shutdown
    echo.
) else (
    echo.
    echo ERROR: Failed to create symlink
    echo.
)

pause
