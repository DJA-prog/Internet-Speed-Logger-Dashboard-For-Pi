# Internet Speed Logger with Web Dashboard

A comprehensive Python application that automatically performs internet speed tests at regular intervals, logs results to CSV, and provides a beautiful web interface for viewing data with interactive charts.

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
- **Recent Test Attempts**: Live monitoring of service health with error detection
- **Honest Hourly Averaging**: Accurate averages using only properly spaced readings

### System Integration
- **Systemd Services**: Runs as background services with auto-start on boot
- **Admin Panel**: Web-based configuration management
- **Session Management**: Persistent admin authentication
- **Service Management**: Automatic restart on configuration changes
- **Enhanced Error Handling**: Smart retry logic with progressive delays
- **Rate Limiting Protection**: Automatic detection and recovery from speedtest blocking

### Performance Analytics
- **Dynamic Distribution**: Speed distribution charts based on your subscription package
- **Success Rate Tracking**: Monitor performance against ISP targets
- **Historical Analysis**: Long-term trend analysis and statistics
- **Service Health Monitoring**: Real-time visibility into test attempts and failures

## 🚀 Quick Start

### Prerequisites
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install speedtest-cli python3-flask python3-pandas python3-pip git

# Fedora/RHEL
sudo dnf install speedtest-cli python3-flask python3-pandas python3-pip git
```

### Installation

#### Option 1: Git Clone (Recommended)
```bash
# Clone the repository
git clone <your-repo-url>
cd internet_speed_logger

# Copy configuration template
cp config.json.template config.json

# Edit configuration (see Configuration section below)
nano config.json

# Run setup
./setup_web.sh

# Start services
./manage_all_services.sh
```

#### Option 2: Complete Setup Script
```bash
# Install and start everything
./setup_web.sh

# Manage all services
./manage_all_services.sh
```

## 🆕 Recent Improvements & Features

### Honest Hourly Averaging (v2.1)
The dashboard now calculates **honest averages** using only readings that are approximately 60 minutes apart:

- ✅ **Filtered Averages**: Uses only hourly readings (±25min tolerance) for accurate long-term averages
- ✅ **Excludes Irregularities**: Filters out manual tests, service restarts, and different interval periods
- ✅ **Transparent Reporting**: Shows how many readings were used vs excluded
- ✅ **Complete Data**: Min/max values still use all readings for full range information

**Dashboard Display**: "Hourly Avg Download/Upload/Ping" with detailed breakdown showing total vs hourly test counts.

### Recent Test Attempts Monitoring (v2.1)
Real-time visibility into service health and test attempts:

- ✅ **Live Monitoring**: Shows last 5 test attempts with timestamps and status
- ✅ **Error Detection**: Displays HTTP 403 errors, timeouts, and other failures
- ✅ **Service Status**: Real-time service running/stopped indicator
- ✅ **Retry Tracking**: Shows automatic retry attempts and backoff delays
- ✅ **Auto-Refresh**: Updates every 30 seconds with latest attempt information

**Location**: New "Recent Test Attempts" section on main dashboard.

### Enhanced Rate Limiting Protection (v2.1)
Advanced protection against speedtest server blocking:

- ✅ **Smart Retry Logic**: Progressive delays (30s → 2m → 5m) on failures
- ✅ **HTTP 403 Detection**: Automatic backoff when rate limited
- ✅ **Optimized Commands**: Uses `--secure --single --timeout` for better reliability
- ✅ **Adaptive Intervals**: Can automatically increase test intervals after repeated failures

### Automatic Service Management (v2.1)
Admin panel can now automatically restart services after configuration changes:

- ✅ **Seamless Updates**: Change test intervals without manual service restart
- ✅ **Sudo Integration**: Secure, limited permissions for service management
- ✅ **Success Feedback**: Clear confirmation when services restart successfully
- ✅ **Error Handling**: Informative messages if restart fails

### Dashboard Improvements (v2.1)
Enhanced user experience and reliability:

- ✅ **Fixed Chart Loading**: Speed Distribution chart now loads properly on page refresh
- ✅ **Enhanced Tooltips**: Informative tooltips explaining averaging methodology
- ✅ **Better Error Messages**: Clear feedback for service issues and configuration problems
- ✅ **Improved Data Flow**: Optimized loading sequence for faster dashboard updates

## ⚙️ Configuration

### Initial Setup
1. Copy `config.json.template` to `config.json`
2. Update the configuration:

```json
{
  "admin": {
    "username": "admin",
    "password_hash": "YOUR_SECURE_PASSWORD_HASH"
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

### Password Setup
Generate a secure password hash:
```bash
python3 -c "
import hashlib
password = input('Enter admin password: ')
print('Password hash:', hashlib.sha256(password.encode()).hexdigest())
"
```

### Git Safety
This project includes a comprehensive `.gitignore` that excludes:
- ✅ **Data files**: `*.csv`, `*.log` (your speed test results)
- ✅ **Configuration**: `config.json` (contains passwords and settings)
- ✅ **System files**: `*.service` (environment-specific)
- ✅ **Virtual environments**: `venv/`, `env/`
- ✅ **Python cache**: `__pycache__/`, `*.pyc`
- ✅ **IDE files**: `.vscode/`, `.idea/`

#### Safe Files for Git
- ✅ Source code (`.py` files)
- ✅ Templates (`*.html`)
- ✅ Configuration templates (`*.template`)
- ✅ Documentation (`README.md`)
- ✅ Setup scripts (`*.sh`)
- ✅ Requirements files
- ✅ Sample data (`sample_data.csv`)

## 🌐 Web Dashboard

### Access Points
- **Local**: http://localhost:5000
- **Network**: http://YOUR_IP_ADDRESS:5000

### Dashboard Features
- **Interactive Charts**: 
  - Combined speed/ping visualization with dual y-axis
  - Dynamic distribution based on your subscription package
  - Time-filtered views (24h, 7d, 30d, all time)
  - Fixed loading issues - charts now display immediately on page refresh
- **Performance Analytics**:
  - **Honest Hourly Averaging**: Averages calculated from properly spaced readings only
  - Package compliance tracking with transparent methodology
  - Success rate percentages against ISP targets
  - Statistical summaries (avg, min, max) with clear data source indicators
- **Service Health Monitoring**:
  - **Recent Test Attempts**: Live view of last 5 test attempts with status
  - Real-time service status (Running/Stopped) indicator
  - Error detection and retry attempt tracking
  - HTTP 403 rate limiting alerts and recovery status
- **Manual Testing**: 
  - On-demand speed tests with cooldown protection
  - Real-time test status updates
- **Data Management**:
  - CSV export with filtering
  - Responsive design for all devices
  - Auto-refresh every 30 seconds

### Admin Panel
Access the admin panel at: http://localhost:5000/admin

#### Admin Features
- **Dashboard Overview**: 
  - Service status monitoring with detailed health information
  - Recent test statistics with honest averaging breakdown
  - System health indicators and error reporting
- **Subscription Package Management**: 
  - Configure ISP package speeds for performance tracking
  - Single package model for focused analysis
  - Success rate calculations against targets with honest averaging
- **Test Settings**: 
  - Configurable test intervals (0.1 to 24 hours)
  - **Automatic Service Restart**: Changes apply immediately without manual restart
  - Manual test cooldown settings (1-1440 minutes)
  - Real-time feedback on configuration changes
- **Security Management**: 
  - Secure password changes
  - 24-hour persistent sessions
  - SHA256 password hashing
- **Performance Analytics**: 
  - Package compliance tracking
  - Historical performance trends

#### First-Time Admin Setup
1. Access: http://localhost:5000/admin
2. Login with default credentials (see configuration)
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

### Service Management
```bash
# Check service status
sudo systemctl status internet-speed-logger.service
sudo systemctl status internet-speed-web.service

# Start/stop services
sudo systemctl start internet-speed-logger.service
sudo systemctl stop internet-speed-web.service

# View logs
sudo journalctl -u internet-speed-logger.service -f
sudo journalctl -u internet-speed-web.service -f

# Restart all services
./manage_all_services.sh restart
```

### Manual Testing
```bash
# Run a single test
python3 simple_speed_logger.py

# Run with custom interval (in hours)
python3 simple_speed_logger.py 0.5  # Every 30 minutes
```

### Development Mode
```bash
# Run web interface in development mode
python3 web_interface.py
```

## 🔧 Customization

### Adding New Features
The modular design allows easy customization:
- **`simple_speed_logger.py`**: Core testing logic
- **`web_interface.py`**: Flask web application
- **`templates/`**: HTML templates for web interface
- **Configuration**: JSON-based settings management

### Custom Intervals
Configure any interval from 6 minutes to 24 hours:
```json
{
  "test_settings": {
    "interval_hours": 0.1,  // 6 minutes
    "interval_hours": 2.5,  // 2.5 hours
    "interval_hours": 24    // Daily
  }
}
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

### Common Issues

#### Services Won't Start
```bash
# Check if speedtest-cli is installed
which speedtest-cli

# Check service logs
sudo journalctl -u internet-speed-logger.service --since "1 hour ago"

# Verify file permissions
ls -la /home/user01/Desktop/internet_speed_logger/
```

#### Web Interface Not Accessible
```bash
# Check if service is running
sudo systemctl status internet-speed-web.service

# Check if port 5000 is in use
sudo netstat -tlnp | grep :5000

# Check firewall settings
sudo ufw status
```

#### Configuration Issues
```bash
# Validate JSON configuration
python3 -m json.tool config.json

# Reset to defaults
cp config.json.template config.json
```

#### Rate Limiting & HTTP 403 Errors

**Symptoms**: Dashboard shows "Failed: HTTP Error 403 - Speedtest server blocked request"

**Immediate Solutions**:
```bash
# 1. Check recent attempts on dashboard
curl http://localhost:5000/api/recent-attempts | python3 -m json.tool

# 2. Restart service to clear temporary blocks
sudo systemctl restart internet-speed-logger.service

# 3. Increase test interval to reduce frequency
sudo systemctl stop internet-speed-logger.service
# Edit service_runner.sh to change: python3 simple_speed_logger.py 2.0
sudo systemctl start internet-speed-logger.service

# 4. Check service logs for pattern
sudo journalctl -u internet-speed-logger.service --since "6 hours ago" | grep -E "(403|Forbidden|Failed)"
```

**Long-term Prevention**:
```bash
# Monitor blocking status
python3 speedtest_config.py  # Show recommendations

# Use conservative settings
echo "Changing to 2-hour intervals for stability..."
sudo systemctl stop internet-speed-logger.service
sed -i 's/python3 simple_speed_logger.py .*/python3 simple_speed_logger.py 2.0/' service_runner.sh
sudo systemctl start internet-speed-logger.service

# Verify new settings
sudo journalctl -u internet-speed-logger.service -f
```

**Dashboard Monitoring**:
- Check "Recent Test Attempts" section for failure patterns
- Look for repeated 403 errors indicating blocking
- Monitor "Service Status" badge (should show "Service Running")
- Watch for retry attempts and their success/failure

#### Permission Errors
```bash
# Fix file permissions
chmod +x *.sh
chmod 644 *.py *.json *.md

# Fix systemd service files
sudo chmod 644 /etc/systemd/system/internet-speed-*.service
sudo systemctl daemon-reload
```

## 📝 Development

### Git Workflow
```bash
# Clone and setup
git clone <repo-url>
cd internet_speed_logger

# Setup configuration
cp config.json.template config.json
# Edit config.json with your settings

# Install dependencies
./setup_web.sh

# Start development
python3 web_interface.py
```

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Project Structure
```
internet_speed_logger/
├── .gitignore                 # Git ignore rules
├── README.md                  # This documentation
├── config.json.template       # Configuration template
├── sample_data.csv           # Sample data format
├── simple_speed_logger.py    # Core testing logic
├── web_interface.py          # Flask web application
├── templates/                # HTML templates
│   ├── dashboard.html
│   ├── admin_login.html
│   └── admin_dashboard.html
├── setup_web.sh             # Web setup script
├── manage_all_services.sh    # Service management
└── update_interval.sh        # Dynamic configuration updates
```
```bash
# With virtual environment
./run.sh

# Or manually
source venv/bin/activate
python internet_speed_logger.py
```

Run speed tests every 30 minutes:
```bash
./run.sh --interval 0.5
```

Run speed tests every 2 hours:
```bash
./run.sh --interval 2
```

#### Single Test

Run a single speed test:
```bash
./run.sh --single
```

### Using the Simple Version

The simple version (`simple_speed_logger.py`) uses the command-line speedtest-cli tool and doesn't require additional Python packages:

```bash
# Run every hour
python3 simple_speed_logger.py

# Run every 30 minutes
python3 simple_speed_logger.py 0.5

# Run every 2 hours
python3 simple_speed_logger.py 2
```

### Custom Output File

Specify a custom CSV filename:
```bash
python internet_speed_logger.py --output my_speed_log.csv
```

### Command Line Options

- `--interval HOURS`: Hours between speed tests (default: 1, can be decimal like 0.5)
- `--single`: Run a single test instead of continuous testing
- `--output FILENAME`: Output CSV filename (default: internet_speed_log.csv)

## Output Format

The CSV file contains the following columns:

- `timestamp`: Date and time of the test
- `download_speed_mbps`: Download speed in Mbps
- `upload_speed_mbps`: Upload speed in Mbps
- `ping_ms`: Ping latency in milliseconds
- `server_name`: Name of the speedtest server used
- `server_country`: Country of the speedtest server
- `isp`: Internet Service Provider

## Example Output

```csv
timestamp,download_speed_mbps,upload_speed_mbps,ping_ms,server_name,server_country,isp
2025-10-30 14:00:01,85.42,12.34,15.67,Speedtest Server,United States,Comcast
2025-10-30 15:00:02,87.21,11.98,16.23,Speedtest Server,United States,Comcast
```

## Logging

The script creates a log file (`speed_test.log`) that contains detailed information about:
- Test start/completion times
- Errors and exceptions
- Status messages

## Running as System Service

### Quick Setup (Recommended)
```bash
# Run the automated installer
./install_service.sh
```

### Manual Setup
```bash
# Copy service file
sudo cp internet-speed-logger.service /etc/systemd/system/

# Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable internet-speed-logger.service
sudo systemctl start internet-speed-logger.service
```

### Service Management
```bash
# Interactive management tool
./service_manager.sh

# Command line management
./service_manager.sh status     # Check service status
./service_manager.sh start      # Start service
./service_manager.sh stop       # Stop service
./service_manager.sh restart    # Restart service
./service_manager.sh logs       # View recent logs
./service_manager.sh results    # Show CSV results

# Direct systemctl commands
sudo systemctl status internet-speed-logger
sudo systemctl start internet-speed-logger
sudo systemctl stop internet-speed-logger
sudo journalctl -u internet-speed-logger -f
```

## Running in Background

### Option 1: Systemd Service (Recommended)
The systemd service automatically:
- Starts on system boot
- Restarts if it crashes
- Logs to system journal
- Runs with proper user permissions

### Option 2: Screen Session
To run the script continuously in a screen session:

```bash
nohup python internet_speed_logger.py > /dev/null 2>&1 &
```

To stop the background process:
```bash
pkill -f internet_speed_logger.py
```

## Systemd Service (Linux)

For automatic startup on system boot, create a systemd service:

1. Create service file `/etc/systemd/system/internet-speed-logger.service`:
```ini
[Unit]
Description=Internet Speed Logger
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/path/to/internet_speed_logger
ExecStart=/usr/bin/python3 /path/to/internet_speed_logger/internet_speed_logger.py
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
```

2. Enable and start the service:
```bash
sudo systemctl enable internet-speed-logger.service
sudo systemctl start internet-speed-logger.service
```

## Files Overview

### Core Files
- `internet_speed_logger.py` - Full-featured Python logger with extensive options
- `simple_speed_logger.py` - Simplified version using command-line speedtest-cli
- `requirements.txt` - Python dependencies
- `README.md` - This documentation

### Screen Session Scripts
- `setup.sh` - Sets up virtual environment and dependencies
- `run.sh` - Runs full-featured logger in virtual environment  
- `run_in_screen.sh` - Runs full-featured logger in screen session
- `run_simple_in_screen.sh` - Runs simple logger in screen session
- `manage_sessions.sh` - Interactive screen session manager

### Systemd Service Files
- `internet-speed-logger.service` - Systemd service definition
- `service_runner.sh` - Script executed by systemd service
- `service_manager.sh` - Interactive systemd service manager
- `install_service.sh` - Automated service installer

## Requirements

- Python 3.6+
- speedtest-cli library
- Internet connection

## Notes

- The first run may take longer as speedtest-cli needs to download server list
- Speed tests typically take 30-60 seconds to complete
- The script automatically selects the best server based on ping
- Results are appended to the CSV file, so historical data is preserved
- If errors occur during testing, they are logged and the script continues

## 📋 Quick Reference: Blocking Prevention

### Safe Testing Intervals
```bash
# Ultra-safe (recommended for production)
python3 simple_speed_logger.py 2.0    # Every 2 hours (12 tests/day)

# Balanced (default recommended)  
python3 simple_speed_logger.py 1.0    # Every 1 hour (24 tests/day)

# Current default (monitor for 403 errors)
python3 simple_speed_logger.py 0.5    # Every 30 minutes (48 tests/day)
```

### Emergency Commands
```bash
# Check if blocked
curl -s http://localhost:5000/api/recent-attempts | grep -i "403\|failed"

# Restart services after blocking
sudo systemctl restart internet-speed-logger.service

# View real-time logs  
sudo journalctl -u internet-speed-logger.service -f

# Check dashboard for blocking status
# Navigate to: http://localhost:5000 → "Recent Test Attempts" section
```

### Rate Limit Indicators
- ❌ **HTTP 403 Forbidden** = Rate limited/blocked
- ❌ **Cannot retrieve speedtest configuration** = Server overloaded
- ✅ **Speed test completed** = Working normally
- 🔄 **Retry attempts** = Automatic recovery in progress