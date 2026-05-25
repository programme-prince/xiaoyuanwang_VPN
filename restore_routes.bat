@echo off
chcp 65001 >nul

call settings.bat

echo ====== Restore Network Settings ======
echo.

echo [Step 1] Re-enable DHCP default gateway on campus...
netsh interface ipv4 set interface "以太网" ignoredefaultroutes=disabled >nul 2>&1

echo [Step 2] Remove routes...
route delete %SERVER_IP% >nul 2>&1
route delete %CAMPUS_SUBNET% >nul 2>&1

echo [Step 3] Restore campus default route...
route add 0.0.0.0 mask 0.0.0.0 %CAMPUS_GATEWAY% -p >nul 2>&1

echo [Step 4] Reset interface metrics to auto...
netsh interface ipv4 set interface "WLAN" metric=auto >nul 2>&1
netsh interface ipv4 set interface "以太网" metric=auto >nul 2>&1

timeout /t 2 >nul

echo.
echo ====== Restore Complete ======
echo All settings reverted to default.
echo.
pause
