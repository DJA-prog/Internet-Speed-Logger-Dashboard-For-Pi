#!/bin/bash
# Quick deployment script for Internet Speed Logger Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Check if Docker and Docker Compose are installed
check_dependencies() {
    log "Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    log "Dependencies check passed"
}

# Create necessary directories
create_directories() {
    log "Creating data directories..."
    mkdir -p data logs
    
    # Set proper permissions
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # On Linux, ensure proper ownership
        sudo chown -R 1000:1000 data logs 2>/dev/null || {
            warn "Could not set ownership for data directories. You may need to run: sudo chown -R 1000:1000 data logs"
        }
    fi
    
    log "Data directories created"
}

# Check for configuration override
check_override() {
    if [ -f "docker-compose.override.yml" ]; then
        info "Found docker-compose.override.yml - using custom configuration"
    else
        info "No override file found. You can copy docker-compose.override.yml.example to customize settings"
    fi
}

# Deploy the application
deploy() {
    log "Starting Internet Speed Logger deployment..."
    
    check_dependencies
    create_directories
    check_override
    
    # Build and start the application
    log "Building Docker image..."
    docker-compose build
    
    log "Starting application..."
    docker-compose up -d
    
    # Wait for application to be ready
    log "Waiting for application to be ready..."
    sleep 10
    
    # Check health
    for i in {1..6}; do
        if curl -f http://localhost:5000/health >/dev/null 2>&1; then
            log "Application is healthy and ready!"
            break
        else
            if [ $i -eq 6 ]; then
                error "Application failed to start properly"
                docker-compose logs
                exit 1
            else
                info "Waiting for application to be ready... (attempt $i/6)"
                sleep 10
            fi
        fi
    done
    
    # Show status
    docker-compose ps
    
    log "Deployment completed successfully!"
    echo ""
    echo "🌐 Web Interface: http://localhost:5000"
    echo "🔐 Default Admin: admin / speedtest123"
    echo "📊 Health Check: http://localhost:5000/health"
    echo ""
    echo "📋 Useful commands:"
    echo "  docker-compose logs -f          # View logs"
    echo "  docker-compose restart          # Restart services"
    echo "  docker-compose down             # Stop services"
    echo "  docker-compose exec internet-speed-logger bash  # Enter container"
    echo ""
}

# Stop the application
stop() {
    log "Stopping Internet Speed Logger..."
    docker-compose down
    log "Application stopped"
}

# Update the application
update() {
    log "Updating Internet Speed Logger..."
    
    # Pull latest changes (if in git repo)
    if [ -d ".git" ]; then
        git pull origin main || warn "Could not pull latest changes from git"
    fi
    
    # Rebuild and restart
    docker-compose build --no-cache
    docker-compose up -d
    
    log "Update completed"
}

# View logs
logs() {
    docker-compose logs -f
}

# Show status
status() {
    echo "=== Container Status ==="
    docker-compose ps
    
    echo ""
    echo "=== Application Health ==="
    if curl -f http://localhost:5000/health 2>/dev/null; then
        echo "✅ Application is healthy"
    else
        echo "❌ Application is not responding"
    fi
    
    echo ""
    echo "=== Data Directory ==="
    if [ -d "data" ]; then
        echo "Data directory: $(du -sh data)"
        if [ -f "data/internet_speed_log.csv" ]; then
            echo "CSV records: $(wc -l < data/internet_speed_log.csv)"
        fi
    fi
    
    echo ""
    echo "=== Recent Logs ==="
    docker-compose logs --tail=10
}

# Backup data
backup() {
    backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    log "Creating backup in $backup_dir..."
    
    mkdir -p "$backup_dir"
    
    if [ -d "data" ]; then
        cp -r data "$backup_dir/"
        log "Data backed up to $backup_dir/data"
    fi
    
    if [ -d "logs" ]; then
        cp -r logs "$backup_dir/"
        log "Logs backed up to $backup_dir/logs"
    fi
    
    # Create compressed archive
    tar -czf "${backup_dir}.tar.gz" -C backups "$(basename "$backup_dir")"
    rm -rf "$backup_dir"
    
    log "Backup completed: ${backup_dir}.tar.gz"
}

# Clean up old data
cleanup() {
    read -p "This will remove old logs and rotate CSV files. Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Cleaning up old data..."
        
        # Rotate CSV if it's large
        if [ -f "data/internet_speed_log.csv" ]; then
            lines=$(wc -l < data/internet_speed_log.csv)
            if [ $lines -gt 50000 ]; then
                mv data/internet_speed_log.csv "data/internet_speed_log_$(date +%Y%m%d).csv"
                log "Rotated large CSV file (${lines} lines)"
            fi
        fi
        
        # Clean old logs
        find logs -name "*.log" -mtime +30 -delete 2>/dev/null || true
        
        log "Cleanup completed"
    fi
}

# Show help
show_help() {
    echo "Internet Speed Logger Docker Manager"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deploy    Deploy the application (default)"
    echo "  stop      Stop the application"
    echo "  restart   Restart the application"
    echo "  update    Update and restart the application"
    echo "  logs      View application logs"
    echo "  status    Show application status"
    echo "  backup    Create backup of data and logs"
    echo "  cleanup   Clean old logs and rotate large CSV files"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy     # Deploy the application"
    echo "  $0 logs       # View logs in real-time"
    echo "  $0 status     # Check application status"
}

# Main script logic
case "${1:-deploy}" in
    "deploy")
        deploy
        ;;
    "stop")
        stop
        ;;
    "restart")
        stop
        deploy
        ;;
    "update")
        update
        ;;
    "logs")
        logs
        ;;
    "status")
        status
        ;;
    "backup")
        backup
        ;;
    "cleanup")
        cleanup
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac