#!/bin/bash

# Internet Speed Logger - Complete Service Manager
# Manages both the speed logger and web interface services

SPEED_SERVICE="internet-speed-logger.service"
WEB_SERVICE="internet-speed-web.service"

show_header() {
    echo "================================================"
    echo "  Internet Speed Logger - Complete Manager"
    echo "================================================"
}

show_services_status() {
    echo ""
    echo "Services Status:"
    echo "=================="
    echo ""
    echo "📊 Speed Logger Service:"
    sudo systemctl status $SPEED_SERVICE --no-pager -l | head -6
    echo ""
    echo "🌐 Web Interface Service:"
    sudo systemctl status $WEB_SERVICE --no-pager -l | head -6
}

show_menu() {
    echo ""
    echo "Available commands:"
    echo "Speed Logger:"
    echo "  1. Start speed logger"
    echo "  2. Stop speed logger"
    echo "  3. Restart speed logger"
    echo "  4. Speed logger logs"
    echo ""
    echo "Web Interface:"
    echo "  5. Start web interface"
    echo "  6. Stop web interface"
    echo "  7. Restart web interface"
    echo "  8. Web interface logs"
    echo ""
    echo "Both Services:"
    echo "  9. Start both services"
    echo " 10. Stop both services"
    echo " 11. Restart both services"
    echo " 12. Show full status"
    echo ""
    echo "Data & Results:"
    echo " 13. Show recent speed results"
    echo " 14. Open web dashboard"
    echo " 15. Download CSV data"
    echo ""
    echo " 0. Exit"
    echo ""
}

show_full_status() {
    echo ""
    echo "Full System Status:"
    echo "==================="
    echo ""
    echo "📊 Speed Logger Service:"
    echo "------------------------"
    sudo systemctl status $SPEED_SERVICE --no-pager -l
    echo ""
    echo "🌐 Web Interface Service:"
    echo "-------------------------"
    sudo systemctl status $WEB_SERVICE --no-pager -l
    echo ""
    echo "🔧 System Info:"
    echo "---------------"
    echo "Local IP: $(hostname -I | awk '{print $1}')"
    echo "Web Dashboard: http://localhost:5000"
    echo "External Access: http://$(hostname -I | awk '{print $1}'):5000"
}

show_logs() {
    local service=$1
    local service_name=$2
    echo ""
    echo "Recent logs for $service_name:"
    echo "==============================="
    sudo journalctl -u $service --no-pager -l -n 20
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
        echo "Data file: $(pwd)/internet_speed_log.csv"
    else
        echo "No results file found (internet_speed_log.csv)"
    fi
}

open_dashboard() {
    local ip=$(hostname -I | awk '{print $1}')
    echo ""
    echo "Web Dashboard URLs:"
    echo "==================="
    echo "Local:    http://localhost:5000"
    echo "Network:  http://$ip:5000"
    echo ""
    
    # Try to open in browser
    if command -v xdg-open &> /dev/null; then
        read -p "Open dashboard in browser? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            xdg-open "http://localhost:5000"
        fi
    else
        echo "Copy one of the URLs above into your web browser."
    fi
}

download_csv() {
    if [ -f "internet_speed_log.csv" ]; then
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_file="internet_speed_log_backup_$timestamp.csv"
        cp internet_speed_log.csv "$backup_file"
        echo ""
        echo "CSV data copied to: $backup_file"
        echo "Original file: internet_speed_log.csv"
        echo ""
        echo "You can also download from the web interface:"
        echo "http://localhost:5000 → Download CSV button"
    else
        echo "No CSV file found to download."
    fi
}

# Main script
show_header

if [ $# -eq 0 ]; then
    # Interactive mode
    show_services_status
    
    while true; do
        show_menu
        read -p "Choose an option (0-15): " choice
        
        case $choice in
            1)
                echo "Starting speed logger service..."
                sudo systemctl start $SPEED_SERVICE
                echo "Speed logger started."
                ;;
            2)
                echo "Stopping speed logger service..."
                sudo systemctl stop $SPEED_SERVICE
                echo "Speed logger stopped."
                ;;
            3)
                echo "Restarting speed logger service..."
                sudo systemctl restart $SPEED_SERVICE
                echo "Speed logger restarted."
                ;;
            4)
                show_logs $SPEED_SERVICE "Speed Logger"
                ;;
            5)
                echo "Starting web interface service..."
                sudo systemctl start $WEB_SERVICE
                echo "Web interface started."
                ;;
            6)
                echo "Stopping web interface service..."
                sudo systemctl stop $WEB_SERVICE
                echo "Web interface stopped."
                ;;
            7)
                echo "Restarting web interface service..."
                sudo systemctl restart $WEB_SERVICE
                echo "Web interface restarted."
                ;;
            8)
                show_logs $WEB_SERVICE "Web Interface"
                ;;
            9)
                echo "Starting both services..."
                sudo systemctl start $SPEED_SERVICE $WEB_SERVICE
                echo "Both services started."
                ;;
            10)
                echo "Stopping both services..."
                sudo systemctl stop $SPEED_SERVICE $WEB_SERVICE
                echo "Both services stopped."
                ;;
            11)
                echo "Restarting both services..."
                sudo systemctl restart $SPEED_SERVICE $WEB_SERVICE
                echo "Both services restarted."
                ;;
            12)
                show_full_status
                ;;
            13)
                show_results
                ;;
            14)
                open_dashboard
                ;;
            15)
                download_csv
                ;;
            0)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option. Please choose 0-15."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
else
    # Command line mode
    case $1 in
        "status")
            show_services_status
            ;;
        "start")
            sudo systemctl start $SPEED_SERVICE $WEB_SERVICE
            echo "Both services started."
            ;;
        "stop")
            sudo systemctl stop $SPEED_SERVICE $WEB_SERVICE
            echo "Both services stopped."
            ;;
        "restart")
            sudo systemctl restart $SPEED_SERVICE $WEB_SERVICE
            echo "Both services restarted."
            ;;
        "logs")
            show_logs $SPEED_SERVICE "Speed Logger"
            show_logs $WEB_SERVICE "Web Interface"
            ;;
        "results")
            show_results
            ;;
        "dashboard")
            open_dashboard
            ;;
        *)
            echo "Usage: $0 [status|start|stop|restart|logs|results|dashboard]"
            echo "       $0 (interactive mode)"
            exit 1
            ;;
    esac
fi