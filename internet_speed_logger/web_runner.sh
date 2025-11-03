#!/bin/bash

# Internet Speed Logger Web Server Runner
# This script runs both the speed logger and web interface

# Set working directory
cd /home/user01/Desktop/internet_speed_logger

# Set up logging
exec > >(logger -t internet-speed-web -p user.info) 2>&1

echo "Internet Speed Logger Web Interface starting..."
echo "Working directory: $(pwd)"
echo "User: $(whoami)"
echo "Date: $(date)"

# Check if Flask is available
python3 -c "import flask" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "ERROR: Flask not found. Installing dependencies..."
    if [ -d "venv" ]; then
        source venv/bin/activate
        pip install flask pandas
    else
        pip3 install --user flask pandas
    fi
fi

echo "Starting web interface on port 5000..."

# Run the web interface
exec python3 web_interface.py