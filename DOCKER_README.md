# Internet Speed Logger - Docker Deployment

This directory contains Docker configuration for running the Internet Speed Logger application in containers.

## 🐳 What's Included

- **Dockerfile**: Multi-stage build optimized for Python application
- **docker-compose.yml**: Complete orchestration with data persistence
- **docker-entrypoint.sh**: Smart startup script with initialization
- **.dockerignore**: Optimized build context

## 🚀 Quick Start

### Prerequisites

- Docker 20.10+ and Docker Compose 2.0+
- Internet connection for speed tests

### Simple Deployment

1. **Clone and Navigate**
   ```bash
   git clone <repository-url>
   cd internet_speed_logger_docker
   ```

2. **Start with Docker Compose**
   ```bash
   docker-compose up -d
   ```

3. **Access the Application**
   - Web Interface: http://localhost:5000
   - Default Admin: `admin` / `speedtest123`

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

The application persists data in mounted volumes:

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
      - TEST_INTERVAL_HOURS=0.5
    ports:
      - "8080:5000"
```

## 🔧 Service Management

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

# Test speedtest-cli
docker run internet-speed-logger test
```

## 🏥 Health Monitoring

### Built-in Health Check

The container includes automatic health monitoring:

```bash
# Check container health
docker ps
# HEALTHY/UNHEALTHY status shown

# View health check logs
docker inspect internet-speed-logger --format='{{json .State.Health}}'
```

### Manual Health Check

```bash
# Test application health
curl http://localhost:5000/health

# Container health check
docker exec internet-speed-logger /docker-entrypoint.sh health
```

## 🌐 Production Deployment

### With Nginx Reverse Proxy

Enable the Nginx service for production:

```bash
# Start with Nginx proxy
docker-compose --profile production up -d
```

Create `nginx.conf` for custom proxy configuration:

```nginx
events {
    worker_connections 1024;
}

http {
    upstream app {
        server internet-speed-logger:5000;
    }
    
    server {
        listen 80;
        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

### Security Considerations

1. **Change Default Credentials**
   ```bash
   export ADMIN_USERNAME=secure_admin
   export ADMIN_PASSWORD=very_secure_password
   ```

2. **Use HTTPS in Production**
   - Configure SSL certificates in `./ssl/`
   - Update Nginx configuration for HTTPS

3. **Network Security**
   - Use custom Docker networks
   - Limit port exposure
   - Enable firewall rules

## 🔍 Troubleshooting

### Common Issues

1. **Speedtest Command Not Found**
   ```bash
   # Check if speedtest-cli is installed
   docker exec internet-speed-logger speedtest --version
   ```

2. **Permission Denied**
   ```bash
   # Fix data directory permissions
   sudo chown -R 1000:1000 ./data ./logs
   ```

3. **Port Already in Use**
   ```bash
   # Use different port
   docker-compose up -d -p 8080:5000
   ```

4. **CSV File Corruption**
   ```bash
   # Backup and recreate
   docker exec internet-speed-logger cp /app/data/internet_speed_log.csv /app/data/backup.csv
   docker exec internet-speed-logger rm /app/data/internet_speed_log.csv
   docker-compose restart
   ```

### Debugging

```bash
# Enter container for debugging
docker exec -it internet-speed-logger bash

# View real-time logs
docker-compose logs -f internet-speed-logger

# Check container resource usage
docker stats internet-speed-logger
```

## 📊 Monitoring

### Log Analysis

```bash
# View speed test results
docker exec internet-speed-logger tail -f /app/logs/speed_test.log

# Monitor web interface
docker exec internet-speed-logger tail -f /app/logs/flask.log

# Check CSV data
docker exec internet-speed-logger head -20 /app/data/internet_speed_log.csv
```

### Data Export

```bash
# Export CSV data
docker cp internet-speed-logger:/app/data/internet_speed_log.csv ./backup.csv

# Export configuration
docker cp internet-speed-logger:/app/data/config.json ./config_backup.json
```

## 🔄 Updates

### Application Updates

```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose build --no-cache
docker-compose up -d
```

### Data Migration

```bash
# Backup data before updates
docker exec internet-speed-logger tar -czf /tmp/backup.tar.gz /app/data
docker cp internet-speed-logger:/tmp/backup.tar.gz ./backup_$(date +%Y%m%d).tar.gz
```

## 📈 Performance Optimization

### Resource Limits

Add to `docker-compose.yml`:

```yaml
services:
  internet-speed-logger:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
```

### Storage Optimization

```bash
# Clean old logs (monthly)
docker exec internet-speed-logger find /app/logs -name "*.log" -mtime +30 -delete

# Rotate CSV files if they get too large
docker exec internet-speed-logger bash -c 'if [ $(wc -l < /app/data/internet_speed_log.csv) -gt 100000 ]; then mv /app/data/internet_speed_log.csv /app/data/internet_speed_log_$(date +%Y%m).csv; fi'
```

---

## 🆘 Support

For issues and questions:

1. Check the troubleshooting section above
2. Review container logs: `docker-compose logs`
3. Test speedtest connectivity: `docker exec internet-speed-logger speedtest`
4. Verify configuration: `docker exec internet-speed-logger cat /app/data/config.json`

Happy speed testing! 🚀