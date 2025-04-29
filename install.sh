#!/bin/bash
# Installation script for network health monitoring service

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "Installing Network Health Monitoring Service..."

# Copy the monitoring script
echo "Installing monitoring script..."
cp network-health-check.sh /usr/local/bin/
chmod +x /usr/local/bin/network-health-check.sh

# Copy systemd service file
echo "Installing systemd service..."
cp network-health.service /etc/systemd/system/

# Reload systemd
echo "Reloading systemd..."
systemctl daemon-reload

# Enable and start the service
echo "Enabling and starting service..."
systemctl enable network-health.service
systemctl start network-health.service

# Check service status
echo "Service status:"
systemctl status network-health.service --no-pager

echo ""
echo "Installation complete!"
echo "You can view logs with: journalctl -u network-health.service -f"
echo "To modify settings, edit /usr/local/bin/network-health-check.sh"
