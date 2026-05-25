# Run: powershell -ExecutionPolicy Bypass -File monitor.ps1
# Or set as default: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

$settings = Join-Path $PSScriptRoot "settings.ps1"
if (Test-Path $settings) { . $settings }

while ($true) {
    Clear-Host
    Write-Host "===== VPN Traffic Monitor ====="
    Write-Host ((Get-Date).ToString("yyyy/MM/dd HH:mm:ss"))
    Write-Host "Press Ctrl+C to exit"
    Write-Host ""

    Write-Host "-- Default Gateways --"
    route print | Select-String "0.0.0.0          0.0.0.0"

    Write-Host ""
    Write-Host "-- Route for server --"
    if ($SERVER_IP) { route print | Select-String $SERVER_IP }
    else { Write-Host "  (No SERVER_IP configured in settings.ps1)" }

    Write-Host ""
    Write-Host "-- Quick Test --"
    if ($TEST_IP) { $r = ping $TEST_IP -n 1 -w 2000 *>$null; if ($LASTEXITCODE -eq 0) { Write-Host "  $TEST_IP`: OK" } else { Write-Host "  $TEST_IP`: timeout" } }
    if ($SERVER_IP) { $r = ping $SERVER_IP -n 1 -w 2000 *>$null; if ($LASTEXITCODE -eq 0) { Write-Host "  Server: OK" } else { Write-Host "  Server: timeout" } }

    Start-Sleep -Seconds 3
}
