# Run: powershell -ExecutionPolicy Bypass -File check_network.ps1

Write-Host "============ Network Status ============="
Write-Host ""

route print | Select-String "0.0.0.0          0.0.0.0"

Write-Host ""
Write-Host "--- How to read ---"
Write-Host "If hotspot metric is smaller: VPN goes through hotspot [SAFE]"
Write-Host "If campus metric is smaller : VPN goes through campus [RISK]"

Read-Host "Press Enter"
