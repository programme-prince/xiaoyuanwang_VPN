@echo off
echo ============ Network Status ============
echo.
route print | findstr "0.0.0.0          0.0.0.0"
echo.
echo --- How to read ---
echo If hotspot metric is smaller: VPN goes through hotspot [SAFE]
echo If campus metric is smaller : VPN goes through campus [RISK]
echo.
pause
