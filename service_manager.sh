#!/bin/bash

# Internet Speed Logger - Systemd Service Manager

SERVICE_NAME="internet-speed-logger.service"

show_header() {
    echo "========================================"
    echo "  Internet Speed Logger Service Manager"
    echo "========================================"
}

show_status() {
    echo ""
    echo "Service Status:"
    echo "---------------"
    sudo systemctl status $SERVICE_NAME --no-pager -l
}

show_logs() {
    echo ""
    echo "Recent Service Logs:"
    echo "-------------------"
    sudo journalctl -u $SERVICE_NAME --no-pager -l -n 20
}

show_menu() {
    echo ""
    echo "Available commands:"
    echo "1. Show service status"
    echo "2. Start service"
    echo "3. Stop service" 
    echo "4. Restart service"
    echo "5. Enable service (auto-start on boot)"
    echo "6. Disable service (don't auto-start on boot)"
    echo "7. Show recent logs"
    echo "8. Show real-time logs"
    echo "9. Show CSV results"
    echo "0. Exit"
    echo ""
}

show_results() {
    if [ -f "internet_speed_log.csv" ]; then
        echo ""
        echo "Recent Speed Test Results:"
        echo "=========================="
        echo "Timestamp,Download(Mbps),Upload(Mbps),Ping(ms)"
        echo "-------------------------------------------------"
        tail -10 internet_speed_log.csv | cut -d',' -f1,2,3,4 | column -t -s ','
        echo ""
        echo "Total tests recorded: $(( $(wc -l < internet_speed_log.csv) - 1 ))"
    else
        echo "No results file found (internet_speed_log.csv)"
    fi
}

# Main script
show_header

if [ $# -eq 0 ]; then
    # Interactive mode
    show_status
    
    while true; do
        show_menu
        read -p "Choose an option (0-9): " choice
        
        case $choice in
            1)
                show_status
                ;;
            2)
                echo "Starting service..."
                sudo systemctl start $SERVICE_NAME
                echo "Service started."
                show_status
                ;;
            3)
                echo "Stopping service..."
                sudo systemctl stop $SERVICE_NAME
                echo "Service stopped."
                show_status
                ;;
            4)
                echo "Restarting service..."
                sudo systemctl restart $SERVICE_NAME
                echo "Service restarted."
                show_status
                ;;
            5)
                echo "Enabling service for auto-start..."
                sudo systemctl enable $SERVICE_NAME
                echo "Service enabled."
                ;;
            6)
                echo "Disabling service auto-start..."
                sudo systemctl disable $SERVICE_NAME
                echo "Service disabled."
                ;;
            7)
                show_logs
                ;;
            8)
                echo "Showing real-time logs (Ctrl+C to exit)..."
                sudo journalctl -u $SERVICE_NAME -f
                ;;
            9)
                show_results
                ;;
            0)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option. Please choose 0-9."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
else
    # Command line mode
    case $1 in
        "status")
            show_status
            ;;
        "start")
            sudo systemctl start $SERVICE_NAME
            echo "Service started."
            ;;
        "stop")
            sudo systemctl stop $SERVICE_NAME
            echo "Service stopped."
            ;;
        "restart")
            sudo systemctl restart $SERVICE_NAME
            echo "Service restarted."
            ;;
        "enable")
            sudo systemctl enable $SERVICE_NAME
            echo "Service enabled for auto-start."
            ;;
        "disable")
            sudo systemctl disable $SERVICE_NAME
            echo "Service disabled from auto-start."
            ;;
        "logs")
            show_logs
            ;;
        "follow")
            sudo journalctl -u $SERVICE_NAME -f
            ;;
        "results")
            show_results
            ;;
        *)
            echo "Usage: $0 [status|start|stop|restart|enable|disable|logs|follow|results]"
            echo "       $0 (interactive mode)"
            exit 1
            ;;
    esac
fi