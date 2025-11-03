#!/bin/bash

# Internet Speed Logger - Screen Runner Script

SESSION_NAME="speed_logger"

echo "Starting Internet Speed Logger in screen session..."

# Check if screen is installed
if ! command -v screen &> /dev/null; then
    echo "Error: screen is not installed. Install it with: sudo apt install screen"
    exit 1
fi

# Check if session already exists
if screen -list | grep -q "$SESSION_NAME"; then
    echo "Screen session '$SESSION_NAME' already exists."
    echo "Options:"
    echo "1. Attach to existing session: screen -r $SESSION_NAME"
    echo "2. Kill existing session and start new: screen -S $SESSION_NAME -X quit && screen -dmS $SESSION_NAME"
    echo "3. List all sessions: screen -list"
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Virtual environment not found. Running setup.sh first..."
    if [ -f "setup.sh" ]; then
        chmod +x setup.sh
        ./setup.sh
    else
        echo "Error: setup.sh not found. Please run setup first."
        exit 1
    fi
fi

# Start screen session with the speed logger
echo "Creating screen session '$SESSION_NAME'..."
screen -dmS "$SESSION_NAME" bash -c "
    cd /home/user01/Desktop/internet_speed_logger
    source venv/bin/activate
    echo 'Starting Internet Speed Logger...'
    echo 'Press Ctrl+A, then D to detach from this screen session'
    echo 'Use: screen -r $SESSION_NAME to reattach'
    echo ''
    python internet_speed_logger.py
"

# Give it a moment to start
sleep 2

# Check if session was created successfully
if screen -list | grep -q "$SESSION_NAME"; then
    echo "✓ Screen session '$SESSION_NAME' started successfully!"
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