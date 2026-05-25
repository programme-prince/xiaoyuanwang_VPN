@echo off
call settings.bat

:loop
cls
echo ===== VPN Traffic Monitor =====
echo (%date% %time%)
echo Press Ctrl+C to exit
echo.

echo -- Default Gateways --
route print | findstr "0.0.0.0          0.0.0.0"
echo.

echo -- Route for server --
route print | findstr "%SERVER_IP%"
echo.

echo -- Quick Test --
ping %TEST_IP% -n 1 -w 2000 >nul && echo %TEST_IP%: OK || echo %TEST_IP%: timeout
ping %SERVER_IP% -n 1 -w 2000 >nul && echo Server: OK || echo Server: timeout

echo.
timeout /t 3 >nul
goto loop
