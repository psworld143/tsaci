@echo off
REM Get Local IP Address for TSACI Mobile Configuration
REM This script helps you find your machine's IP address to configure mobile devices

echo =========================================
echo TSACI - Get IP Address for Mobile Setup
echo =========================================
echo.

echo Platform: Windows
echo.
echo Detecting your local IP addresses...
echo.

REM Get IPv4 address
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set IP=%%a
    set IP=!IP:~1!
    if not "!IP:~0,3!"=="127" (
        if not "!IP:~0,3!"=="169" (
            echo ✓ Your IP Address: !IP!
            echo.
            echo Configuration Steps:
            echo 1. Edit: lib\core\constants\api_constants.dart
            echo 2. Find the line with 'return 'http://localhost/tsaci/backend';'
            echo 3. Replace with: return 'http://!IP!/tsaci/backend';
            echo.
            echo Test in mobile browser: http://!IP!/tsaci/backend
            echo.
        )
    )
)

echo.
echo =========================================
echo For more details, see: API_CONFIGURATION.md
echo =========================================
echo.
pause

