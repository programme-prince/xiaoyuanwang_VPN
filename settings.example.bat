@echo off
REM ===== Network Configuration =====
REM Edit the values below, then run fix_routes.bat to apply.

REM Your school server IP address
set SERVER_IP=YOUR_SERVER_IP

REM Campus network gateway (usually 192.168.1.1)
set CAMPUS_GATEWAY=YOUR_CAMPUS_GATEWAY

REM Campus subnet (usually no need to change)
set CAMPUS_SUBNET=YOUR_CAMPUS_SUBNET
set CAMPUS_MASK=255.255.255.0

REM Hotspot metric - lower = higher priority (keep at 10)
set HOTSPOT_METRIC=10

REM Campus metric - higher = lower priority (keep at 100)
set CAMPUS_METRIC=100

REM External IP for connectivity test (8.8.8.8 or 114.114.114.114)
set TEST_IP=8.8.8.8
