@echo off
chcp 65001 >nul

call settings.bat

echo Fixing network interface metrics...

echo Step 1: Set WLAN (hotspot) metric = %HOTSPOT_METRIC%
netsh interface ipv4 set interface "WLAN" metric=%HOTSPOT_METRIC%

echo Step 2: Set Ethernet (campus) metric = %CAMPUS_METRIC%
netsh interface ipv4 set interface "以太网" metric=%CAMPUS_METRIC%

echo Step 3: Add route for server %SERVER_IP%
route add %SERVER_IP% mask 255.255.255.255 %CAMPUS_GATEWAY% -p >nul 2>&1

echo Done.
pause
