@echo off
setlocal enabledelayedexpansion

for %%i in ("%~dp0") do set "SCRIPT_DIR=%%~fi"
set "LOG=%SCRIPT_DIR%\butler.log"
set "SOURCE=%2"
set "TARGET=%3"

echo Log file: %LOG%

if "%1"=="--help" (
    echo Your happy little itch.io helper
    exit /b 0
)

if "%1"=="push" (
    echo SUCCESS: Push called, source=%SOURCE%, target=%TARGET% >> "%LOG%"
    exit /b 0
)

echo FAIL: Invalid arguments: %* >> "%LOG%"
exit /b 100
