#!/bin/bash

# Internet Speed Logger - Systemd Service Installer

echo "Internet Speed Logger - Systemd Service Setup"
echo "=============================================="

# Check if running as root for some operations
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        echo "This script requires sudo privileges for systemd operations."
        echo "You may be prompted for your password."
    fi
}

# Install dependencies if needed
install_dependencies() {
    echo "Checking dependencies..."
    
    missing_deps=()
    
    if ! command -v speedtest-cli &> /dev/null; then
        missing_deps+=("speedtest-cli")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Missing dependencies: ${missing_deps[*]}"
        read -p "Install missing dependencies? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo apt update
            sudo apt install -y "${missing_deps[@]}"
        else
            echo "Cannot proceed without dependencies."
            exit 1
        fi
    else
        echo "All dependencies are installed."
    fi
}

# Main installation
main() {
    check_sudo
    install_dependencies
    
    echo ""
    echo "Setting up systemd service..."
    
    # Make scripts executable
    chmod +x service_runner.sh service_manager.sh
    
    # Copy service file to systemd
    sudo cp internet-speed-logger.service /etc/systemd/system/
    
    # Reload systemd
    sudo systemctl daemon-reload
    
    # Enable service
    sudo systemctl enable internet-speed-logger.service
    
    echo ""
    echo "✓ Service installed and enabled successfully!"
    echo ""
    echo "Available commands:"
    echo "• Start service:     sudo systemctl start internet-speed-logger"
    echo "• Stop service:      sudo systemctl stop internet-speed-logger"
    echo "• Service status:    sudo systemctl status internet-speed-logger"
    echo "• View logs:         sudo journalctl -u internet-speed-logger"
    echo "• Manage service:    ./service_manager.sh"
    echo ""
    
    read -p "Start the service now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo systemctl start internet-speed-logger.service
        echo ""
        echo "Service started! Checking status..."
        sudo systemctl status internet-speed-logger.service --no-pager
        echo ""
        echo "The service will now run automatically on system boot."
        echo "Use ./service_manager.sh to manage the service."
    fi
}

main "$@"