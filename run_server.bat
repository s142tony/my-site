@echo off
title Local Web Server for Portfolio
cls
echo ===================================================
echo             Local Portfolio Web Server
echo ===================================================
echo.

REM 1. Check if Python is already installed and working
python --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PY_CMD=python"
    goto start_server
)

py --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PY_CMD=py"
    goto start_server
)

REM 2. Python not found - Trigger Auto Installation of Python 3.10.11
echo [WARNING] Python is NOT installed on this system!
echo [INFO] Starting automatic download and setup for Python 3.10.11...
echo.

set "INSTALLER=python-3.10.11-amd64.exe"
set "DOWNLOAD_URL=https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe"

REM Download using curl or fallback to PowerShell
where curl >nul 2>&1
if %errorlevel% equ 0 (
    echo Downloading Python 3.10 installer via curl...
    curl -L -o "%INSTALLER%" "%DOWNLOAD_URL%"
) else (
    echo Downloading Python 3.10 installer via PowerShell...
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%INSTALLER%')"
)

if not exist "%INSTALLER%" (
    echo [ERROR] Failed to download Python installer. Please check your internet connection!
    goto exit_script
)

echo.
echo Installing Python 3.10 in background (this may take 1-2 minutes)...
echo Please wait...
"%INSTALLER%" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0

REM Clean up downloaded installer
del /f /q "%INSTALLER%" >nul 2>&1

REM 3. Locate newly installed Python binary
set "LOCAL_PY=%LocalAppData%\Programs\Python\Python310\python.exe"
if exist "%LOCAL_PY%" (
    set "PY_CMD=%LOCAL_PY%"
    echo.
    echo [SUCCESS] Python 3.10 installed successfully!
    echo.
    goto start_server
)

set "GLOBAL_PY=C:\Program Files\Python310\python.exe"
if exist "%GLOBAL_PY%" (
    set "PY_CMD=%GLOBAL_PY%"
    echo.
    echo [SUCCESS] Python 3.10 installed successfully!
    echo.
    goto start_server
)

echo.
echo [ERROR] Installation finished, but Python binary could not be located.
echo Please restart this script or manually run index.html.
goto exit_script

:start_server
echo [INFO] Python executable ready.
echo [INFO] Starting local HTTP server on port 8000...
echo [INFO] Opening browser at http://localhost:8000
echo.
echo Press Ctrl+C in this window to stop the server.
echo ---------------------------------------------------
start http://localhost:8000
"%PY_CMD%" -m http.server 8000

if %errorlevel% neq 0 (
    echo.
    echo [WARNING] Port 8000 failed. Trying Port 8080...
    start http://localhost:8080
    "%PY_CMD%" -m http.server 8080
)

:exit_script
echo.
echo Process finished.
pause