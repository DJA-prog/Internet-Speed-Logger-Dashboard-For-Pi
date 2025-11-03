#!/usr/bin/env python3
"""
Simple Internet Speed Logger
A simplified version that can work with system-installed packages.
"""

import csv
import time
import datetime
import subprocess
import json
import os
import logging

class SimpleSpeedLogger:
    def __init__(self, csv_filename="internet_speed_log.csv"):
        self.csv_filename = csv_filename
        self.csv_headers = [
            "timestamp", 
            "download_speed_mbps", 
            "upload_speed_mbps", 
            "ping_ms"
        ]
        
        # Set up logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)
        
        # Initialize CSV file
        self._initialize_csv()
    
    def _initialize_csv(self):
        """Initialize CSV file with headers if it doesn't exist."""
        if not os.path.exists(self.csv_filename):
            with open(self.csv_filename, 'w', newline='') as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(self.csv_headers)
            self.logger.info(f"Created new CSV file: {self.csv_filename}")
    
    def perform_speed_test(self):
        """Perform speed test using speedtest-cli command."""
        try:
            self.logger.info("Starting speed test...")
            
            # Run speedtest-cli with JSON output
            result = subprocess.run(
                ['speedtest-cli', '--json'], 
                capture_output=True, 
                text=True, 
                timeout=120
            )
            
            if result.returncode != 0:
                raise Exception(f"speedtest-cli failed: {result.stderr}")
            
            data = json.loads(result.stdout)
            
            # Extract data and convert to Mbps
            download_mbps = round(data['download'] / 1_000_000, 2)
            upload_mbps = round(data['upload'] / 1_000_000, 2)
            ping_ms = round(data['ping'], 2)
            
            results = {
                "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "download_speed_mbps": download_mbps,
                "upload_speed_mbps": upload_mbps,
                "ping_ms": ping_ms
            }
            
            self.logger.info(f"Speed test completed: {download_mbps} Mbps down, "
                           f"{upload_mbps} Mbps up, {ping_ms} ms ping")
            
            return results
            
        except subprocess.TimeoutExpired:
            self.logger.error("Speed test timed out")
            return self._error_result()
        except Exception as e:
            self.logger.error(f"Speed test failed: {str(e)}")
            return self._error_result()
    
    def _error_result(self):
        """Return error result."""
        return {
            "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "download_speed_mbps": "ERROR",
            "upload_speed_mbps": "ERROR",
            "ping_ms": "ERROR"
        }
    
    def log_to_csv(self, results):
        """Log results to CSV."""
        try:
            with open(self.csv_filename, 'a', newline='') as csvfile:
                writer = csv.writer(csvfile)
                row = [results[header] for header in self.csv_headers]
                writer.writerow(row)
            self.logger.info(f"Results logged to {self.csv_filename}")
        except Exception as e:
            self.logger.error(f"Failed to write to CSV: {str(e)}")
    
    def run_continuous(self, interval_hours=1):
        """Run continuous speed tests."""
        interval_seconds = interval_hours * 3600
        self.logger.info(f"Starting continuous speed testing every {interval_hours} hour(s)")
        self.logger.info("Press Ctrl+C to stop")
        
        try:
            while True:
                results = self.perform_speed_test()
                self.log_to_csv(results)
                self.logger.info(f"Waiting {interval_hours} hour(s) until next test...")
                time.sleep(interval_seconds)
        except KeyboardInterrupt:
            self.logger.info("Speed testing stopped by user")

if __name__ == "__main__":
    import sys
    
    # Check if speedtest-cli is available
    try:
        subprocess.run(['speedtest-cli', '--version'], 
                      capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error: speedtest-cli is not installed or not in PATH")
        print("Install it with: sudo apt install speedtest-cli")
        print("Or: pip install speedtest-cli")
        sys.exit(1)
    
    # Get interval from command line argument
    interval = 1
    if len(sys.argv) > 1:
        try:
            interval = float(sys.argv[1])
        except ValueError:
            print("Usage: python simple_speed_logger.py [interval_hours]")
            sys.exit(1)
    
    logger = SimpleSpeedLogger()
    logger.run_continuous(interval_hours=interval)