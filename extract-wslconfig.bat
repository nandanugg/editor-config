@echo off
REM Extract .wslconfig from Windows user directory to local configs folder

echo.
echo ========================================
echo Extract WSL Configuration
echo ========================================
echo.

REM Destination is the configs folder in the current directory
set "DEST_DIR=%~dp0configs"
set "DEST_FILE=%DEST_DIR%\.wslconfig"

REM Source is the user's home directory
set "SOURCE_FILE=%USERPROFILE%\.wslconfig"

echo Source: %SOURCE_FILE%
echo Destination: %DEST_FILE%
echo.

REM Check if source exists
if not exist "%SOURCE_FILE%" (
    echo ERROR: .wslconfig file not found in %USERPROFILE%
    echo.
    pause
    exit /b 1
)

REM Ensure configs directory exists
if not exist "%DEST_DIR%" (
    md "%DEST_DIR%"
)

REM Copy the file
echo Copying .wslconfig...
copy /Y "%SOURCE_FILE%" "%DEST_FILE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCCESS: .wslconfig extracted successfully!
    echo ========================================
    echo.
) else (
    echo.
    echo ERROR: Failed to copy file
    echo.
)

pause