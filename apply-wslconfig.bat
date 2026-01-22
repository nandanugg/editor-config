@echo off
REM Apply .wslconfig from local configs folder to Windows user directory

echo.
echo ========================================
echo Apply WSL Configuration
echo ========================================
echo.

REM Get the current directory (should be the WSL mount path like \\wsl$\...)
set "SOURCE_DIR=%~dp0configs"

REM Check if .wslconfig exists
if not exist "%SOURCE_DIR%\.wslconfig" (
    echo ERROR: .wslconfig file not found in %SOURCE_DIR%
    echo.
    pause
    exit /b 1
)

REM Destination is the user's home directory
set "DEST_FILE=%USERPROFILE%\.wslconfig"
set "SOURCE_FILE=%SOURCE_DIR%\.wslconfig"

echo Source: %SOURCE_FILE%
echo Destination: %DEST_FILE%
echo.

REM Copy the file
echo Copying .wslconfig...
copy /Y "%SOURCE_FILE%" "%DEST_FILE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCCESS: .wslconfig copied successfully!
    echo ========================================
    echo.
    echo IMPORTANT: You need to restart WSL for changes to take effect.
    echo Run this command from PowerShell or CMD:
    echo     wsl --shutdown
    echo.
) else (
    echo.
    echo ERROR: Failed to copy file
    echo.
)

pause