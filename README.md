# Network Health Monitoring Service

A systemd service that monitors network connectivity and automatically restarts NetworkManager when connection issues are detected.

## Overview

This package provides a reliable solution for systems that need to maintain network connectivity. It periodically checks network availability by pinging a well-known host (e.g., google.com) and takes corrective action when connectivity fails.

### Key Features

- Automatic detection of network connectivity issues
- Configurable thresholds for determining when to restart NetworkManager
- Detailed logging of all events and actions
- Runs as a systemd service with appropriate security hardening
- Easy installation and configuration

## Installation

### Quick Install

1. Clone or download this repository
2. Make the installation script executable:
   ```
   chmod +x install-network-health-service.sh
   ```
3. Run the installation script with root privileges:
   ```
   sudo ./install-network-health-service.sh
   ```

### Manual Installation

If you prefer to install manually:

1. Copy `network-health-check.sh` to `/usr/local/bin/` and make it executable:
   ```
   sudo cp network-health-check.sh /usr/local/bin/
   sudo chmod +x /usr/local/bin/network-health-check.sh
   ```

2. Copy the service file to the systemd directory:
   ```
   sudo cp network-health.service /etc/systemd/system/
   ```

3. Reload systemd, then enable and start the service:
   ```
   sudo systemctl daemon-reload
   sudo systemctl enable network-health.service
   sudo systemctl start network-health.service
   ```

## Configuration

The monitoring script can be customized by editing `/usr/local/bin/network-health-check.sh`. The most important configuration variables are at the top of the file:

| Variable | Default | Description |
|----------|---------|-------------|
| `HOST_TO_CHECK` | google.com | Host to ping for connectivity testing |
| `PING_COUNT` | 3 | Number of ping attempts per check |
| `PING_TIMEOUT` | 5 | Timeout in seconds for each ping attempt |
| `MAX_FAILURES` | 3 | Number of consecutive failures before restarting NetworkManager |
| `CHECK_INTERVAL` | 60 | Interval in seconds between connectivity checks |
| `LOG_FILE` | /var/log/network-health.log | Log file location |

After making changes, restart the service:
```
sudo systemctl restart network-health.service
```

## Monitoring and Troubleshooting

### View Service Status

```
sudo systemctl status network-health.service
```

### View Logs

View the service logs through journalctl:
```
sudo journalctl -u network-health.service -f
```

Check the dedicated log file:
```
sudo tail -f /var/log/network-health.log
```

### Common Issues

#### Service Won't Start

Check for syntax errors in the script:
```
bash -n /usr/local/bin/network-health-check.sh
```

Verify permissions:
```
ls -l /usr/local/bin/network-health-check.sh
```

#### Not Detecting Network Issues

Ensure the script can ping the configured host when your network is working properly:
```
ping -c 3 google.com
```

Consider editing the script to use a different `HOST_TO_CHECK` that's reliably accessible from your network.

## Uninstalling

To remove the service:

```
sudo systemctl stop network-health.service
sudo systemctl disable network-health.service
sudo rm /etc/systemd/system/network-health.service
sudo rm /usr/local/bin/network-health-check.sh
sudo systemctl daemon-reload
```

## Security Considerations

The service is configured with systemd security hardening options to minimize potential security risks:
- `ProtectSystem=full`: Read-only access to /usr and /boot
- `PrivateTmp=true`: Private /tmp directory
- `NoNewPrivileges=true`: Prevents privilege escalation
- Several other protections to limit system access

## License

This software is released under the MIT License. See the LICENSE file for details.
