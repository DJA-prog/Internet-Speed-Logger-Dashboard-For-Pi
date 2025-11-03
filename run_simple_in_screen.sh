#!/bin/bash

# Simple Internet Speed Logger - Screen Runner Script

SESSION_NAME="simple_speed_logger"

echo "Starting Simple Internet Speed Logger in screen session..."

# Check if screen is installed
if ! command -v screen &> /dev/null; then
    echo "Error: screen is not installed. Install it with: sudo apt install screen"
    exit 1
fi

# Check if speedtest-cli is available
if ! command -v speedtest-cli &> /dev/null; then
    echo "Error: speedtest-cli is not installed."
    echo "Install it with: sudo apt install speedtest-cli"
    echo "Or: pip install speedtest-cli"
    exit 1
fi

# Check if session already exists
if screen -list | grep -q "$SESSION_NAME"; then
    echo "Screen session '$SESSION_NAME' already exists."
    echo "Options:"
    echo "1. Attach to existing session: screen -r $SESSION_NAME"
    echo "2. Kill existing session: screen -S $SESSION_NAME -X quit"
    echo "3. List all sessions: screen -list"
    exit 1
fi

# Get interval from command line argument (default: 1 hour)
INTERVAL=${1:-1}

# Start screen session with the simple speed logger
echo "Creating screen session '$SESSION_NAME' with $INTERVAL hour interval..."
screen -dmS "$SESSION_NAME" bash -c "
    cd /home/user01/Desktop/internet_speed_logger
    echo 'Starting Simple Internet Speed Logger...'
    echo 'Testing every $INTERVAL hour(s)'
    echo 'Press Ctrl+A, then D to detach from this screen session'
    echo 'Use: screen -r $SESSION_NAME to reattach'
    echo ''
    python3 simple_speed_logger.py $INTERVAL
"

# Give it a moment to start
sleep 2

# Check if session was created successfully
if screen -list | grep -q "$SESSION_NAME"; then
    echo "✓ Screen session '$SESSION_NAME' started successfully!"
    echo ""
    echo "Configuration:"
    echo "• Test interval: $INTERVAL hour(s)"
    echo "• Session name: $SESSION_NAME"
    echo ""
    echo "Useful commands:"
    echo "• Attach to session:    screen -r $SESSION_NAME"
    echo "• List all sessions:    screen -list"
    echo "• Detach from session:  Ctrl+A, then D"
    echo "• Kill session:         screen -S $SESSION_NAME -X quit"
    echo ""
    echo "The speed logger is now running in the background."
    echo "Check the CSV file for results: cat internet_speed_log.csv"
else
    echo "✗ Failed to start screen session."
    exit 1
fi