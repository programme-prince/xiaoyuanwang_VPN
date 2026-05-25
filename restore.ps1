# Run as Administrator: powershell -ExecutionPolicy Bypass -File restore.ps1

# Load settings
$settings = Join-Path $PSScriptRoot "settings.ps1"
if (Test-Path $settings) { . $settings } else { Write-Host "settings.ps1 not found!" -ForegroundColor Red; exit }

Write-Host "Restoring network settings..."
Write-Host ""

# Delete routes
Write-Host "Deleting server route: $SERVER_IP..."
route delete $SERVER_IP *>$null

Write-Host "Deleting campus subnet route: $CAMPUS_SUBNET..."
route delete $CAMPUS_SUBNET *>$null

# Find campus interface by IP
$campusAdapter = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.1.*" } | Get-NetAdapter -ErrorAction SilentlyContinue
if ($campusAdapter) {
    Write-Host "Resetting campus metric to auto: $($campusAdapter.Name)..."
    $campusAdapter | Set-NetIPInterface -InterfaceMetric $null
}

# Find hotspot interface by IP
$hotspotAdapter = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.114.*" } | Get-NetAdapter -ErrorAction SilentlyContinue
if ($hotspotAdapter) {
    Write-Host "Resetting hotspot metric to auto: $($hotspotAdapter.Name)..."
    $hotspotAdapter | Set-NetIPInterface -InterfaceMetric $null
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Read-Host "Press Enter"
