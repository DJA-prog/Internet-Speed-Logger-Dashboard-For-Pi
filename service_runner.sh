#!/bin/bash

# Internet Speed Logger Service Runner
# This script is executed by systemd

# Set working directory
cd /home/user01/Desktop/internet_speed_logger

# Set up logging
exec > >(logger -t internet-speed-logger -p user.info) 2>&1

echo "Internet Speed Logger Service starting..."
echo "Working directory: $(pwd)"
echo "User: $(whoami)"
echo "Date: $(date)"

# Check if speedtest-cli is available
if ! command -v speedtest-cli &> /dev/null; then
    echo "ERROR: speedtest-cli not found in PATH"
    echo "Available in PATH: $PATH"
    exit 1
fi

echo "speedtest-cli found: $(which speedtest-cli)"

# Check if the simple speed logger exists
if [ ! -f "simple_speed_logger.py" ]; then
    echo "ERROR: simple_speed_logger.py not found"
    exit 1
fi

echo "Starting simple speed logger with 1 hour interval..."

# Run the simple speed logger
exec python3 simple_speed_logger.py 0.5