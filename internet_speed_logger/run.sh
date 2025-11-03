#!/bin/bash

# Internet Speed Logger Run Script

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Virtual environment not found. Please run setup.sh first."
    exit 1
fi

# Activate virtual environment
source venv/bin/activate

# Run the speed logger
python internet_speed_logger.py "$@"