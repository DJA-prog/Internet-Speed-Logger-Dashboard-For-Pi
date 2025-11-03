#!/bin/bash

# Internet Speed Logger - Screen Session Manager

echo "Internet Speed Logger - Screen Session Manager"
echo "=============================================="

# Check if screen is installed
if ! command -v screen &> /dev/null; then
    echo "Error: screen is not installed. Install it with: sudo apt install screen"
    exit 1
fi

# Function to show menu
show_menu() {
    echo ""
    echo "Available options:"
    echo "1. Start full-featured logger in screen"
    echo "2. Start simple logger in screen"
    echo "3. List all screen sessions"
    echo "4. Attach to speed_logger session"
    echo "5. Attach to simple_speed_logger session"
    echo "6. Kill speed_logger session"
    echo "7. Kill simple_speed_logger session"
    echo "8. Kill all speed logger sessions"
    echo "9. Show CSV results"
    echo "0. Exit"
    echo ""
}

# Function to list sessions
list_sessions() {
    echo "Active screen sessions:"
    screen -list | grep -E "(speed|Speed)" || echo "No speed logger sessions found."
}

# Function to show CSV results
show_results() {
    if [ -f "internet_speed_log.csv" ]; then
        echo "Recent speed test results:"
        echo "=========================="
        tail -10 internet_speed_log.csv | column -t -s ','
    else
        echo "No results file found (internet_speed_log.csv)"
    fi
}

# Main menu loop
while true; do
    show_menu
    read -p "Choose an option (0-9): " choice
    
    case $choice in
        1)
            echo "Starting full-featured logger..."
            ./run_in_screen.sh
            ;;
        2)
            read -p "Enter test interval in hours (default: 1): " interval
            interval=${interval:-1}
            echo "Starting simple logger with $interval hour interval..."
            ./run_simple_in_screen.sh $interval
            ;;
        3)
            list_sessions
            ;;
        4)
            if screen -list | grep -q "speed_logger"; then
                echo "Attaching to speed_logger session..."
                screen -r speed_logger
            else
                echo "speed_logger session not found."
            fi
            ;;
        5)
            if screen -list | grep -q "simple_speed_logger"; then
                echo "Attaching to simple_speed_logger session..."
                screen -r simple_speed_logger
            else
                echo "simple_speed_logger session not found."
            fi
            ;;
        6)
            if screen -list | grep -q "speed_logger"; then
                screen -S speed_logger -X quit
                echo "speed_logger session terminated."
            else
                echo "speed_logger session not found."
            fi
            ;;
        7)
            if screen -list | grep -q "simple_speed_logger"; then
                screen -S simple_speed_logger -X quit
                echo "simple_speed_logger session terminated."
            else
                echo "simple_speed_logger session not found."
            fi
            ;;
        8)
            echo "Killing all speed logger sessions..."
            screen -list | grep -E "(speed_logger|simple_speed_logger)" | awk '{print $1}' | while read session; do
                screen -S "$session" -X quit
                echo "Terminated: $session"
            done
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