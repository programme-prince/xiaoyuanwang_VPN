# ===== Network Configuration Template =====
# Copy this file to settings.ps1 and fill in your own values.
# Then run fix_routes.ps1 to apply.

# Your school server IP address
$SERVER_IP = "YOUR_SERVER_IP"

# Campus network gateway
$CAMPUS_GATEWAY = "YOUR_CAMPUS_GATEWAY"

# Campus subnet
$CAMPUS_SUBNET = "YOUR_CAMPUS_SUBNET"
$CAMPUS_MASK = "255.255.255.0"

# External IP for connectivity test
$TEST_IP = "8.8.8.8"
