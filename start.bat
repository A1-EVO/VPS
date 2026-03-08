@echo off
setlocal enabledelayedexpansion

:: Prompt for physical disk number
echo.
echo === QEMU Boot from PhysicalDrive ===
echo.
wmic diskdrive get index,model,size
echo.
set /p disknum=Enter the PhysicalDrive number (e.g., 1 for \\.\PhysicalDrive1): 

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Administrator privileges required. Please run this file as Administrator.
    pause
    exit /b
)

:: QEMU path (adjust if installed elsewhere)
set QEMU_PATH="C:\Program Files\qemu"
cd /d %QEMU_PATH%

:: Launch QEMU
echo.
echo Launching QEMU from \\.\PhysicalDrive%disknum% ...
.\qemu-system-x86_64.exe -m 2048 -hda \\.\PhysicalDrive%disknum% -boot order=d -net none

pause
