# Internet Speed Logger with Web Dashboard - Docker Edition

A comprehensive Docker-based Python application that automatically performs internet speed tests at regular intervals, logs results to CSV, and provides a beautiful web interface for viewing data with interactive charts.

## ✨ Features

### Core Functionality
- **Automated Testing**: Performs download, upload, and ping tests using speedtest.net
- **Flexible Scheduling**: Configurable test intervals (minutes to hours)
- **Manual Testing**: Run tests on-demand with cooldown protection
- **Data Persistence**: Stores results in CSV format for easy analysis

### Web Interface
- **Modern Dashboard**: Responsive Bootstrap 5 interface with Chart.js visualizations
- **Interactive Charts**: Combined speed/ping charts with dual y-axis
- **Package Performance**: Track ISP package compliance with success rates
- **Real-time Updates**: Auto-refreshing dashboard every 30 seconds
- **Time Filtering**: View data for 24h, 7d, 30d, or all time
- **Data Export**: Download CSV data with filtering options

### Docker Integration
- **Containerized Deployment**: One-command deployment with Docker Compose
- **Data Persistence**: Volumes for CSV logs and configuration
- **Production Ready**: Includes Nginx reverse proxy and SSL configuration
- **Health Monitoring**: Built-in health checks and status monitoring
- **Easy Management**: Comprehensive management scripts and utilities

### Performance Analytics
- **Dynamic Distribution**: Speed distribution charts based on your subscription package
- **Success Rate Tracking**: Monitor performance against ISP targets
- **Historical Analysis**: Long-term trend analysis and statistics

## � Quick Start with Docker

### Prerequisites
- Docker 20.10+
- Docker Compose 2.0+
- Internet connection for speed tests

### Simple Deployment

1. **Clone the Repository**
   ```bash
   git clone https://github.com/DJA-prog/Internet-Speed-Logger-Dashboard-For-Pi.git
   cd Internet-Speed-Logger-Dashboard-For-Pi
   ```

2. **Deploy with Docker Compose**
   ```bash
   # Quick deployment
   ./manage.sh deploy
   
   # Or manually
   docker-compose up -d
   ```

3. **Access the Application**
   - 🌐 **Web Interface**: http://localhost:5000
   - 🔐 **Default Admin**: `admin` / `speedtest123`
   - 📊 **Health Check**: http://localhost:5000/health

### Manual Docker Build

```bash
# Build the image
docker build -t internet-speed-logger .

# Run with data persistence
docker run -d \
  --name internet-speed-logger \
  -p 5000:5000 \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/logs:/app/logs \
  internet-speed-logger
```

## 📁 Data Persistence

The Docker application persists data in mounted volumes:

```
./data/                     # Created automatically
├── config.json            # Application configuration
└── internet_speed_log.csv  # Speed test results

./logs/                     # Created automatically
├── speed_test.log          # Application logs
└── flask.log              # Web interface logs
```

## ⚙️ Configuration

### Environment Variables

The Docker application supports configuration via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `ADMIN_USERNAME` | `admin` | Web interface admin username |
| `ADMIN_PASSWORD` | `speedtest123` | Web interface admin password |
| `TEST_INTERVAL_HOURS` | `1` | Hours between speed tests |
| `MANUAL_COOLDOWN_MINUTES` | `15` | Cooldown between manual tests |
| `FLASK_ENV` | `production` | Flask environment |

### Docker Compose Override

Create `docker-compose.override.yml` for custom settings:

```yaml
version: '3.8'
services:
  internet-speed-logger:
    environment:
      - ADMIN_USERNAME=your_admin
      - ADMIN_PASSWORD=your_secure_password
      - TEST_INTERVAL_HOURS=2.0
    ports:
      - "8080:5000"
```

### Initial Configuration Setup

The Docker container automatically initializes configuration on first run. You can customize settings via:

1. **Environment Variables** (recommended for Docker)
2. **Web Admin Panel** (http://localhost:5000/admin)
3. **Direct Config File** (edit `./data/config.json`)

Example configuration:
```json
{
  "admin": {
    "username": "admin",
    "password_hash": "hashed_password"
  },
  "subscription_package": {
    "name": "Your ISP Package Name",
    "download": 100.0,
    "upload": 10.0
  },
  "test_settings": {
    "interval_hours": 1.0,
    "manual_cooldown_minutes": 15,
    "last_updated": null
  }
}
```
## 🔧 Docker Management

### Container Commands

```bash
# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Update and restart
docker-compose pull && docker-compose up -d
```

### Management Script

The included `manage.sh` script provides comprehensive management:

```bash
# Deploy the application
./manage.sh deploy

# Check status
./manage.sh status

# View logs
./manage.sh logs

# Create backup
./manage.sh backup

# Update application
./manage.sh update

# Stop application
./manage.sh stop
```

### Service Modes

The container supports different startup modes:

```bash
# Run both speed logger and web interface (default)
docker run internet-speed-logger both

# Run only speed logger
docker run internet-speed-logger speed-logger

# Run only web interface
docker run internet-speed-logger web

# Health check
docker run internet-speed-logger health
```

### Production Deployment

For production with Nginx reverse proxy:

```bash
# Start with Nginx proxy
docker-compose --profile production up -d
```

Configure SSL by placing certificates in `./ssl/` and updating `nginx.conf`.

## 🏥 Health Monitoring

### Built-in Health Checks

```bash
# Check container health
docker ps  # Shows HEALTHY/UNHEALTHY status

# Manual health check
curl http://localhost:5000/health

# Container health check
docker exec internet-speed-logger /docker-entrypoint.sh health
```

### Health Check Response

The health endpoint returns detailed status:

```json
{
  "status": "healthy",
  "timestamp": "2025-11-03T10:30:00",
  "checks": {
    "config": "ok",
    "csv_writable": "ok", 
    "data_access": "ok",
    "total_records": 1250
  }
}
```

## 🌐 Web Dashboard

### Access Points
- **Local**: http://localhost:5000
- **Network**: http://YOUR_IP_ADDRESS:5000

### Dashboard Features
- **Interactive Charts**: 
  - Combined speed/ping visualization with dual y-axis
  - Dynamic distribution based on your subscription package
  - Time-filtered views (24h, 7d, 30d, all time)
- **Performance Analytics**:
  - Package compliance tracking
  - Success rate percentages
  - Statistical summaries (avg, min, max)
- **Manual Testing**: 
  - On-demand speed tests with cooldown protection
  - Real-time test status updates
- **Data Management**:
  - CSV export with filtering
  - Responsive design for all devices

### Admin Panel
Access the admin panel at: http://localhost:5000/admin

#### Admin Features
- **Dashboard Overview**: 
  - Service status monitoring
  - Recent test statistics
  - System health indicators
- **Subscription Package Management**: 
  - Configure ISP package speeds for performance tracking
  - Single package model for focused analysis
  - Success rate calculations against targets
- **Test Settings**: 
  - Configurable test intervals (0.1 to 24 hours)
  - Manual test cooldown settings (1-1440 minutes)
  - Real-time configuration updates
- **Security Management**: 
  - Secure password changes
  - 24-hour persistent sessions
  - SHA256 password hashing

#### First-Time Admin Setup
1. Access: http://localhost:5000/admin
2. Login with default credentials (`admin` / `speedtest123`)
3. **Important**: Change the default password immediately
4. Configure your ISP package details
5. Set desired test intervals

## 📊 Data Analysis

### CSV Format
The application generates CSV files with the following structure:
```csv
timestamp,download_speed_mbps,upload_speed_mbps,ping_ms
2025-11-03 10:00:00,95.2,8.5,15.3
2025-11-03 11:00:00,102.1,9.8,12.7
```

### Performance Metrics
- **Package Compliance**: Tracks success rates against ISP targets
- **Distribution Analysis**: Speed distribution relative to subscription package
- **Historical Trends**: Long-term performance analysis
- **Statistical Summaries**: Average, minimum, maximum values

## 🛠️ Advanced Usage

### Container Management
```bash
# Enter container for debugging
docker exec -it internet-speed-logger bash

# View real-time logs
docker-compose logs -f internet-speed-logger

# Check container resource usage
docker stats internet-speed-logger

# Export data
docker cp internet-speed-logger:/app/data/internet_speed_log.csv ./backup.csv
```

### Custom Docker Build
```bash
# Build with custom tags
docker build -t my-speed-logger:v1.0 .

# Run with custom environment
docker run -d \
  --name my-speed-logger \
  -p 5000:5000 \
  -e ADMIN_USERNAME=myuser \
  -e ADMIN_PASSWORD=mypassword \
  -e TEST_INTERVAL_HOURS=2 \
  -v $(pwd)/data:/app/data \
  my-speed-logger:v1.0
```

### Development Mode
```bash
# Run in development mode with live reload
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Or set environment variables
export FLASK_ENV=development
export FLASK_DEBUG=true
docker-compose up
```

## 🔄 Updates and Backups

### Updating the Application
```bash
# Using management script
./manage.sh update

# Manual update
git pull origin main
docker-compose build --no-cache
docker-compose up -d
```

### Data Backup and Recovery
```bash
# Create backup
./manage.sh backup

# Manual backup
docker exec internet-speed-logger tar -czf /tmp/backup.tar.gz /app/data
docker cp internet-speed-logger:/tmp/backup.tar.gz ./backup_$(date +%Y%m%d).tar.gz

# Restore backup
tar -xzf backup_20251103.tar.gz
docker-compose down
cp -r backup_data/* ./data/
docker-compose up -d
```

## ⚠️ Important: Rate Limiting & Blocking Prevention

### Why Speedtest Gets Blocked

Speedtest.net and other speed testing services implement rate limiting to prevent abuse and manage server load. **Common blocking triggers include:**

- **🚫 Too frequent testing**: >50 tests per day from same IP
- **🚫 Automated patterns**: Regular intervals detected as bot traffic  
- **🚫 Server overload**: Popular servers reject requests during peak hours
- **🚫 Geographic restrictions**: Some servers limit certain regions
- **🚫 HTTP 403 Forbidden**: Most common blocking response

### Optimal Testing Frequency

| **Interval** | **Daily Tests** | **Status** | **Recommendation** |
|--------------|-----------------|------------|-------------------|
| 15 minutes   | 96 tests        | ❌ **High Risk** | Likely to be blocked |
| 30 minutes   | 48 tests        | ⚠️ **Moderate Risk** | Current default, monitor for 403 errors |
| 1 hour       | 24 tests        | ✅ **Recommended** | Optimal balance |
| 2 hours      | 12 tests        | ✅ **Conservative** | Safest for long-term monitoring |
| 6 hours      | 4 tests         | ✅ **Minimal** | Basic monitoring |

### Enhanced Protection Features

This application includes **advanced protection** against rate limiting:

#### Smart Retry Logic
```
1st Failure → Wait 30 seconds → Retry
2nd Failure → Wait 2 minutes → Retry  
3rd Failure → Wait 5 minutes → Final attempt
All Failed → Log error and wait for next interval
```

#### Optimized Speedtest Commands
```bash
# Enhanced command with protection
speedtest-cli --json --secure --single --timeout 60

# Options explained:
--secure  # Uses HTTPS (more reliable)
--single  # Single connection (reduces server load)
--timeout # Prevents hanging connections
```

#### Error Detection & Recovery
- **HTTP 403 Detection**: Automatic backoff on rate limit errors
- **Progressive Delays**: Increasing wait times for repeated failures
- **Service Health Monitoring**: Dashboard shows recent attempts and failures
- **Adaptive Intervals**: Automatically increases interval after repeated blocks

### Best Practices to Avoid Blocking

#### ✅ Recommended Settings
```bash
# Change default interval from 30 minutes to 1 hour
sudo systemctl stop internet-speed-logger.service
# Edit service to use: python3 simple_speed_logger.py 1.0
sudo systemctl start internet-speed-logger.service
```

#### ✅ Timing Strategies
- **Best Times**: 2-6 AM local time (off-peak hours)
- **Avoid**: 6-10 PM local time (peak usage)
- **Spread Tests**: Don't run multiple manual tests rapidly

#### ✅ Server Selection
```bash
# Use closest servers for better reliability
speedtest-cli --list | head -5  # Show nearest servers
speedtest-cli --server 4255     # Use specific server ID
```

### Monitoring Block Status

The **Recent Test Attempts** section on the dashboard shows:
- ✅ **Successful tests** with speed results
- ❌ **Failed tests** with specific error messages  
- ⚠️ **HTTP 403 errors** indicating rate limiting
- 🔄 **Retry attempts** and backoff delays
- 📊 **Service health status** (Running/Stopped)

### Recovery from Blocking

If you get blocked (HTTP 403 errors):

1. **Wait**: Most blocks are temporary (1-24 hours)
2. **Increase Interval**: Change to 2+ hour intervals
3. **Check Dashboard**: Monitor "Recent Test Attempts" for patterns
4. **Restart Service**: `sudo systemctl restart internet-speed-logger.service`
5. **Change Servers**: Try different speedtest servers

### Rate Limit Configuration

Use the included configuration tool:
```bash
python3 speedtest_config.py  # Show current recommendations
```

**Example output:**
```
🚀 SPEEDTEST OPTIMIZATION RECOMMENDATIONS
Current interval: 1.0 hours
Daily tests: ~24.0

✅ Current Settings:
  • Testing every 1.0 hours (24.0 tests/day)
  • Using secure HTTPS connections
  • Single connection mode to reduce server load
  • Automatic retry with progressive delays
  • Adaptive interval on repeated failures
```

## 🐛 Troubleshooting

### Common Docker Issues

#### Container Won't Start
```bash
# Check container logs
docker-compose logs internet-speed-logger

# Check if ports are available
sudo netstat -tlnp | grep :5000

# Verify Docker installation
docker --version
docker-compose --version
```

#### Data Permission Issues
```bash
# Fix data directory permissions
sudo chown -R 1000:1000 ./data ./logs

# Or set proper ownership
sudo chown -R $(id -u):$(id -g) ./data ./logs
```

#### Configuration Problems
```bash
# Check health endpoint
curl http://localhost:5000/health

# Validate configuration
docker exec internet-speed-logger cat /app/data/config.json

# Reset configuration
docker-compose down
rm -rf ./data/config.json
docker-compose up -d
```

#### Network Issues
```bash
# Test speedtest connectivity
docker exec internet-speed-logger speedtest --version

# Check DNS resolution
docker exec internet-speed-logger nslookup speedtest.net

# Test manual speedtest
docker exec internet-speed-logger speedtest
```

#### Rate Limiting & HTTP 403 Errors

**Symptoms**: Dashboard shows "Failed: HTTP Error 403 - Speedtest server blocked request"

**Immediate Docker Solutions**:
```bash
# 1. Check application health
curl http://localhost:5000/health

# 2. View recent test attempts
curl http://localhost:5000/api/recent-attempts

# 3. Restart container to clear temporary blocks
docker-compose restart

# 4. Increase test interval via environment variables
echo "TEST_INTERVAL_HOURS=2.0" >> .env
docker-compose up -d

# 5. Check container logs for patterns
docker-compose logs internet-speed-logger | grep -E "(403|Forbidden|Failed)"
```

**Long-term Prevention**:
```bash
# Use conservative settings in docker-compose.override.yml
cat > docker-compose.override.yml << EOF
version: '3.8'
services:
  internet-speed-logger:
    environment:
      - TEST_INTERVAL_HOURS=2.0  # Every 2 hours (safer)
      - MANUAL_COOLDOWN_MINUTES=30
EOF

docker-compose up -d
```

**Dashboard Monitoring**:
- Check "Recent Test Attempts" section at http://localhost:5000
- Monitor health status at http://localhost:5000/health
- Watch container logs: `docker-compose logs -f`

## 📝 Development

### Docker Development Workflow
```bash
# Clone and setup
git clone https://github.com/DJA-prog/Internet-Speed-Logger-Dashboard-For-Pi.git
cd Internet-Speed-Logger-Dashboard-For-Pi

# Create development override
cat > docker-compose.dev.yml << EOF
version: '3.8'
services:
  internet-speed-logger:
    build: .
    environment:
      - FLASK_ENV=development
      - FLASK_DEBUG=true
    volumes:
      - ./app:/app:ro  # Mount source for live reload
EOF

# Start development environment
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

### Project Structure
```
internet_speed_logger_docker/
├── Dockerfile                    # Docker container definition
├── docker-compose.yml           # Docker orchestration
├── docker-entrypoint.sh         # Container startup script
├── manage.sh                     # Management utilities
├── nginx.conf                    # Reverse proxy configuration
├── .dockerignore                # Docker build exclusions
├── DOCKER_README.md             # Docker-specific documentation
├── README.md                    # This documentation
└── app/                         # Application code
    ├── internet_speed_logger.py  # Core testing logic
    ├── web_interface.py          # Flask web application
    ├── requirements.txt          # Python dependencies
    ├── web_requirements.txt      # Web dependencies
    ├── config.json.template      # Configuration template
    └── templates/               # HTML templates
        ├── dashboard.html
        ├── admin_login.html
        └── admin_dashboard.html
```

### Contributing to Docker Version
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/docker-enhancement`
3. Make your changes to Docker configuration or application code
4. Test with: `docker-compose build && docker-compose up`
5. Submit a pull request

### Legacy Installation (Non-Docker)

For traditional installation without Docker, see the [Legacy Installation Guide](LEGACY_INSTALL.md) or use the original scripts in the `app/` directory:

```bash
# Traditional systemd service installation
cd app/
./setup_web.sh
./manage_all_services.sh
```
## 📋 Quick Reference: Docker Commands

### Deployment Commands
```bash
# Quick deployment
./manage.sh deploy

# Manual deployment  
docker-compose up -d

# Production with Nginx
docker-compose --profile production up -d
```

### Management Commands
```bash
# View logs
docker-compose logs -f

# Check status
./manage.sh status

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Update application
./manage.sh update
```

### Troubleshooting Commands
```bash
# Check application health
curl http://localhost:5000/health

# Enter container for debugging
docker exec -it internet-speed-logger bash

# View container stats
docker stats internet-speed-logger

# Check recent test attempts
curl http://localhost:5000/api/recent-attempts
```

### Safe Testing Intervals
```bash
# Ultra-safe (recommended for production)
TEST_INTERVAL_HOURS=2.0    # Every 2 hours (12 tests/day)

# Balanced (default recommended)  
TEST_INTERVAL_HOURS=1.0    # Every 1 hour (24 tests/day)

# Frequent (monitor for 403 errors)
TEST_INTERVAL_HOURS=0.5    # Every 30 minutes (48 tests/day)
```

### Rate Limit Recovery
```bash
# Check if blocked
curl -s http://localhost:5000/api/recent-attempts | grep -i "403\|failed"

# Restart after blocking
docker-compose restart

# Increase test interval
echo "TEST_INTERVAL_HOURS=2.0" >> .env && docker-compose up -d
```

---

## 🆘 Support

### Docker-Specific Issues
1. Check the [Docker README](DOCKER_README.md) for detailed Docker documentation
2. Review container logs: `docker-compose logs`
3. Test health endpoint: `curl http://localhost:5000/health`
4. Verify speedtest connectivity: `docker exec internet-speed-logger speedtest`

### General Application Issues
1. Check the dashboard's "Recent Test Attempts" section
2. Monitor for HTTP 403 errors indicating rate limiting
3. Verify configuration in the admin panel
4. Review the rate limiting section above

### Resources
- **Web Interface**: http://localhost:5000
- **Admin Panel**: http://localhost:5000/admin  
- **Health Check**: http://localhost:5000/health
- **Documentation**: [DOCKER_README.md](DOCKER_README.md)

Happy speed testing with Docker! 🐳🚀