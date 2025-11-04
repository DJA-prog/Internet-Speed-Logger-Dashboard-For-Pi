# Use Python 3.11 slim image for smaller size
FROM python:3.11-slim as base

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install speedtest-cli from Ookla (official)
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
RUN apt-get update && apt-get install -y speedtest && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create app user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy requirements first for better caching
COPY app/requirements.txt app/web_requirements.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt -r web_requirements.txt

# Copy application code
COPY app/ ./

# Create necessary directories and set permissions
RUN mkdir -p /app/data /app/logs /app/templates && \
    chown -R appuser:appuser /app && \
    chmod +x *.py

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Expose web interface port
EXPOSE 5000

# Set default environment variables
ENV CSV_FILE=/app/data/internet_speed_log.csv
ENV CONFIG_FILE=/app/data/config.json
ENV LOG_DIR=/app/logs
ENV FLASK_APP=web_interface.py
ENV FLASK_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Use entrypoint script
ENTRYPOINT ["/docker-entrypoint.sh"]

# Default command runs both services
CMD ["both"]