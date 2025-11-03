#!/bin/bash

# Internet Speed Logger Setup Script

echo "Setting up Internet Speed Logger..."

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install speedtest-cli

echo "Setup complete!"
echo ""
echo "To run the speed logger:"
echo "1. Activate the virtual environment: source venv/bin/activate"
echo "2. Run the script: python internet_speed_logger.py"
echo ""
echo "Or use the run script: ./run.sh"