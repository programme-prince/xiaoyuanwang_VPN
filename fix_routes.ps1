# Run as Administrator: powershell -ExecutionPolicy Bypass -File fix_routes.ps1

# Load settings
$settings = Join-Path $PSScriptRoot "settings.ps1"
if (Test-Path $settings) { . $settings } else { Write-Host "settings.ps1 not found!" -ForegroundColor Red; exit }

Write-Host "Detecting network interfaces by IP..."
Write-Host ""

# Find campus interface (has IP in campus subnet)
$campusIP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.1.*" } | Select-Object -First 1
$campusAdapter = $campusIP | Get-NetAdapter -ErrorAction SilentlyContinue
if (-not $campusAdapter) {
    Write-Host "Campus interface not found. Check CAMPUS_GATEWAY in settings.ps1" -ForegroundColor Red
    exit
}
Write-Host "Campus interface: $($campusAdapter.Name) (index: $($campusAdapter.ifIndex))" -ForegroundColor Green

# Find hotspot interface (has IP in hotspot range)
$hotspotIP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.114.*" } | Select-Object -First 1
$hotspotAdapter = $hotspotIP | Get-NetAdapter -ErrorAction SilentlyContinue
if (-not $hotspotAdapter) {
    Write-Host "Hotspot interface not found. Check your hotspot connection." -ForegroundColor Red
    exit
}
Write-Host "Hotspot interface: $($hotspotAdapter.Name) (index: $($hotspotAdapter.ifIndex))" -ForegroundColor Green
Write-Host ""

# Delete old server route first (if exists)
route delete $SERVER_IP *>$null

# Set metrics
Write-Host "Setting hotspot metric = 10..."
$hotspotAdapter | Set-NetIPInterface -InterfaceMetric 10

Write-Host "Setting campus metric = 100..."
$campusAdapter | Set-NetIPInterface -InterfaceMetric 100

# Add route for server with explicit interface index
Write-Host "Adding route: $SERVER_IP -> $CAMPUS_GATEWAY via campus (IF $($campusAdapter.ifIndex))..."
route add $SERVER_IP mask 255.255.255.255 $CAMPUS_GATEWAY IF $($campusAdapter.ifIndex) -p *>$null

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host ""
Write-Host "Verifying route..."
route print | findstr $SERVER_IP

Read-Host "Press Enter"
