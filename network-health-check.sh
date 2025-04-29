#!/bin/bash
# network-health-check.sh - Script to check network connectivity and restart NetworkManager if needed

# Configuration variables
HOST_TO_CHECK="google.com"       # Host to ping for connectivity test
PING_COUNT=3                     # Number of ping attempts per check
PING_TIMEOUT=5                   # Timeout in seconds for each ping attempt
MAX_FAILURES=3                   # Number of consecutive failures before restarting NetworkManager
CHECK_INTERVAL=60                # Interval in seconds between connectivity checks
LOG_FILE="/var/log/network-health.log"  # Log file location

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Ensure log file exists and is writable
touch "$LOG_FILE" 2>/dev/null || {
    echo "Cannot write to log file $LOG_FILE, using /tmp/network-health.log instead"
    LOG_FILE="/tmp/network-health.log"
    touch "$LOG_FILE"
}

# Initialize failure counter
failure_count=0

# Main loop
log "Network health monitoring service started"
log "Configuration: Checking $HOST_TO_CHECK every $CHECK_INTERVAL seconds"
log "Will restart NetworkManager after $MAX_FAILURES consecutive failures"

while true; do
    # Perform connectivity check
    if ping -c "$PING_COUNT" -W "$PING_TIMEOUT" "$HOST_TO_CHECK" > /dev/null 2>&1; then
        # Connectivity successful
        if [ "$failure_count" -gt 0 ]; then
            log "Connectivity restored to $HOST_TO_CHECK after $failure_count failed attempts"
            failure_count=0
        fi
    else
        # Connectivity failed
        failure_count=$((failure_count + 1))
        log "Connectivity check failed (attempt $failure_count/$MAX_FAILURES)"
        
        # Check if we've reached max failures
        if [ "$failure_count" -ge "$MAX_FAILURES" ]; then
            log "Reached $MAX_FAILURES consecutive failures, restarting NetworkManager..."
            
            # Restart NetworkManager
            systemctl restart NetworkManager
            
            # Log the restart attempt
            if [ $? -eq 0 ]; then
                log "NetworkManager service restarted successfully"
            else
                log "Failed to restart NetworkManager service"
            fi
            
            # Reset failure counter
            failure_count=0
            
            # Wait a bit longer after restart to allow network to stabilize
            sleep 30
        fi
    fi
    
    # Wait for next check interval
    sleep "$CHECK_INTERVAL"
done
