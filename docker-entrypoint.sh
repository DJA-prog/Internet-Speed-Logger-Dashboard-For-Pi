#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Create necessary directories and fix permissions
mkdir -p /app/data /app/logs

# Fix ownership of mounted volumes if running as root
if [ "$(id -u)" = "0" ]; then
    chown -R appuser:appuser /app/data /app/logs
fi

# Initialize configuration if it doesn't exist
if [ ! -f "/app/data/config.json" ]; then
    log "Initializing configuration file..."
    
    # Create config from template or default
    if [ -f "/app/config.json.template" ]; then
        # Copy template and replace placeholder values
        cp /app/config.json.template /app/data/config.json
        # Replace placeholder password hash with actual hash
        DEFAULT_HASH=$(echo -n "${ADMIN_PASSWORD:-speedtest123}" | sha256sum | cut -d' ' -f1)
        sed -i "s/CHANGE_THIS_PASSWORD_HASH/$DEFAULT_HASH/g" /app/data/config.json
        # Replace placeholder username if specified
        sed -i "s/\"username\": \"admin\"/\"username\": \"${ADMIN_USERNAME:-admin}\"/g" /app/data/config.json
    else
        cat > /app/data/config.json << EOF
{
  "admin": {
    "username": "${ADMIN_USERNAME:-admin}",
    "password_hash": "$(echo -n "${ADMIN_PASSWORD:-speedtest123}" | sha256sum | cut -d' ' -f1)"
  },
  "subscription_package": {
    "name": "Internet Package",
    "download": 100.0,
    "upload": 10.0
  },
  "test_settings": {
    "interval_hours": ${TEST_INTERVAL_HOURS:-1.0},
    "manual_cooldown_minutes": ${MANUAL_COOLDOWN_MINUTES:-15},
    "last_updated": null
  }
}
EOF
    fi
    log "Configuration file created at /app/data/config.json"
fi

# Initialize CSV file if it doesn't exist
if [ ! -f "/app/data/internet_speed_log.csv" ]; then
    log "Initializing CSV log file..."
    echo "timestamp,download_speed_mbps,upload_speed_mbps,ping_ms,server_name,server_country,isp" > /app/data/internet_speed_log.csv
    log "CSV log file created at /app/data/internet_speed_log.csv"
fi

# Switch to appuser if currently running as root
if [ "$(id -u)" = "0" ]; then
    log "Switching to appuser..."
    exec su appuser -c "exec $0 $*"
fi

# Function to run speed logger
run_speed_logger() {
    log "Starting Internet Speed Logger..."
    cd /app
    exec python3 internet_speed_logger.py
}

# Function to run web interface
run_web_interface() {
    log "Starting Web Interface on port 5000..."
    cd /app
    exec python3 -m flask run --host=0.0.0.0 --port=5000
}

# Function to run both services
run_both() {
    log "Starting both Speed Logger and Web Interface..."
    
    # Start speed logger in background
    cd /app
    python3 internet_speed_logger.py &
    SPEED_LOGGER_PID=$!
    
    # Start web interface in background
    python3 -m flask run --host=0.0.0.0 --port=5000 &
    WEB_INTERFACE_PID=$!
    
    # Function to handle shutdown
    shutdown() {
        log "Shutting down services..."
        kill $SPEED_LOGGER_PID $WEB_INTERFACE_PID 2>/dev/null || true
        wait $SPEED_LOGGER_PID $WEB_INTERFACE_PID 2>/dev/null || true
        log "Services stopped"
        exit 0
    }
    
    # Set up signal handlers
    trap shutdown SIGTERM SIGINT
    
    # Wait for both processes
    wait $SPEED_LOGGER_PID $WEB_INTERFACE_PID
}

# Test speedtest-cli availability
test_speedtest() {
    log "Testing speedtest-cli availability..."
    if command -v speedtest >/dev/null 2>&1; then
        log "speedtest-cli is available"
        speedtest --version
    else
        error "speedtest-cli is not available!"
        exit 1
    fi
}

# Health check endpoint
health_check() {
    log "Health check requested"
    
    # Check if config file exists
    if [ ! -f "/app/data/config.json" ]; then
        error "Configuration file missing"
        exit 1
    fi
    
    # Check if CSV file exists
    if [ ! -f "/app/data/internet_speed_log.csv" ]; then
        error "CSV log file missing"
        exit 1
    fi
    
    # Check if speedtest is available
    if ! command -v speedtest >/dev/null 2>&1; then
        error "speedtest-cli not available"
        exit 1
    fi
    
    log "Health check passed"
    exit 0
}

# Main logic
case "${1:-both}" in
    "speed-logger")
        test_speedtest
        run_speed_logger
        ;;
    "web")
        run_web_interface
        ;;
    "both")
        test_speedtest
        run_both
        ;;
    "health")
        health_check
        ;;
    "test")
        test_speedtest
        log "Test completed successfully"
        ;;
    *)
        error "Unknown command: $1"
        echo "Usage: $0 {speed-logger|web|both|health|test}"
        exit 1
        ;;
esac