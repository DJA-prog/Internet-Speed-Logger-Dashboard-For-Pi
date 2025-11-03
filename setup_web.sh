#!/bin/bash

# Internet Speed Logger Web Setup Script

echo "Internet Speed Logger Web Interface Setup"
echo "=========================================="

# Function to check if running as user01
check_user() {
    if [ "$USER" != "user01" ]; then
        echo "Warning: This script should be run as user01"
    fi
}

# Install Python dependencies
install_dependencies() {
    echo "Installing Python dependencies..."
    
    # Try pip3 first
    if command -v pip3 &> /dev/null; then
        pip3 install --user flask pandas
    else
        echo "pip3 not found, trying pip..."
        if command -v pip &> /dev/null; then
            pip install --user flask pandas
        else
            echo "ERROR: pip not found. Please install pip first."
            exit 1
        fi
    fi
    
    echo "Dependencies installed successfully."
}

# Install web service
install_web_service() {
    echo "Installing web interface service..."
    
    # Copy service file
    sudo cp internet-speed-web.service /etc/systemd/system/
    
    # Reload systemd
    sudo systemctl daemon-reload
    
    # Enable service
    sudo systemctl enable internet-speed-web.service
    
    echo "Web service installed and enabled."
}

# Main function
main() {
    check_user
    install_dependencies
    install_web_service
    
    echo ""
    echo "✓ Web interface setup complete!"
    echo ""
    echo "Available commands:"
    echo "• Start web service:    sudo systemctl start internet-speed-web"
    echo "• Stop web service:     sudo systemctl stop internet-speed-web"
    echo "• Web service status:   sudo systemctl status internet-speed-web"
    echo "• View web logs:        sudo journalctl -u internet-speed-web -f"
    echo ""
    echo "• Start manually:       python3 web_interface.py"
    echo "• Access dashboard:     http://localhost:5000"
    echo ""
    
    read -p "Start the web service now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo systemctl start internet-speed-web.service
        echo ""
        echo "Web service started! Checking status..."
        sleep 2
        sudo systemctl status internet-speed-web.service --no-pager
        echo ""
        echo "🌐 Web dashboard should now be available at: http://localhost:5000"
        echo "   Or from another device: http://$(hostname -I | awk '{print $1}'):5000"
    fi
}

main "$@"