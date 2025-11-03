#!/bin/bash

# Internet Speed Logger - Dynamic Configuration Updater
# This script updates the running service with new configuration

INTERVAL_HOURS=$1
SERVICE_NAME="internet-speed-logger.service"
SERVICE_RUNNER="/home/user01/Desktop/internet_speed_logger/service_runner.sh"

if [ -z "$INTERVAL_HOURS" ]; then
    echo "Usage: $0 <interval_hours>"
    exit 1
fi

echo "Updating Internet Speed Logger service interval to $INTERVAL_HOURS hours..."

# Stop the current service
sudo systemctl stop $SERVICE_NAME

# Wait for service to stop
sleep 2

# Update the service runner script with new interval
sed -i "s/exec python3 simple_speed_logger.py [0-9.]\+/exec python3 simple_speed_logger.py $INTERVAL_HOURS/" "$SERVICE_RUNNER"

# Verify the change
if grep -q "simple_speed_logger.py $INTERVAL_HOURS" "$SERVICE_RUNNER"; then
    echo "Service runner updated successfully"
else
    echo "Error: Failed to update service runner"
    exit 1
fi

# Start the service with new configuration
sudo systemctl start $SERVICE_NAME

# Wait for service to start
sleep 3

# Check if service started successfully
if sudo systemctl is-active --quiet $SERVICE_NAME; then
    echo "Service restarted successfully with interval: $INTERVAL_HOURS hours"
    sudo systemctl status $SERVICE_NAME --no-pager -l | head -8
else
    echo "Error: Service failed to start"
    sudo systemctl status $SERVICE_NAME --no-pager -l
    exit 1
fi