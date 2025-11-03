#!/usr/bin/env python3
"""
Internet Speed Logger
A Python script that performs internet speed tests every hour and logs results to CSV.
"""

import csv
import time
import datetime
import speedtest
import os
import logging
from typing import Dict, Any

class InternetSpeedLogger:
    def __init__(self, csv_filename: str = "internet_speed_log.csv"):
        """
        Initialize the Internet Speed Logger.
        
        Args:
            csv_filename (str): Name of the CSV file to store results
        """
        self.csv_filename = csv_filename
        self.csv_headers = [
            "timestamp", 
            "download_speed_mbps", 
            "upload_speed_mbps", 
            "ping_ms",
            "server_name",
            "server_country",
            "isp"
        ]
        
        # Set up logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('speed_test.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        
        # Initialize CSV file with headers if it doesn't exist
        self._initialize_csv()
    
    def _initialize_csv(self) -> None:
        """Initialize CSV file with headers if it doesn't exist."""
        if not os.path.exists(self.csv_filename):
            with open(self.csv_filename, 'w', newline='') as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(self.csv_headers)
            self.logger.info(f"Created new CSV file: {self.csv_filename}")
    
    def perform_speed_test(self) -> Dict[str, Any]:
        """
        Perform a single internet speed test.
        
        Returns:
            Dict containing speed test results
        """
        try:
            self.logger.info("Starting speed test...")
            
            # Initialize speedtest
            st = speedtest.Speedtest()
            
            # Get best server based on ping
            st.get_best_server()
            
            # Perform download test
            self.logger.info("Testing download speed...")
            download_speed = st.download()
            
            # Perform upload test
            self.logger.info("Testing upload speed...")
            upload_speed = st.upload()
            
            # Get server and connection info
            server_info = st.get_best_server()
            
            # Convert speeds from bits/sec to Mbps
            download_mbps = download_speed / 1_000_000
            upload_mbps = upload_speed / 1_000_000
            
            results = {
                "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "download_speed_mbps": round(download_mbps, 2),
                "upload_speed_mbps": round(upload_mbps, 2),
                "ping_ms": round(server_info["latency"], 2),
                "server_name": server_info["name"],
                "server_country": server_info["country"],
                "isp": st.config["client"]["isp"]
            }
            
            self.logger.info(f"Speed test completed: {download_mbps:.2f} Mbps down, "
                           f"{upload_mbps:.2f} Mbps up, {server_info['latency']:.2f} ms ping")
            
            return results
            
        except Exception as e:
            self.logger.error(f"Speed test failed: {str(e)}")
            # Return error data
            return {
                "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "download_speed_mbps": "ERROR",
                "upload_speed_mbps": "ERROR",
                "ping_ms": "ERROR",
                "server_name": "ERROR",
                "server_country": "ERROR",
                "isp": "ERROR"
            }
    
    def log_to_csv(self, results: Dict[str, Any]) -> None:
        """
        Log speed test results to CSV file.
        
        Args:
            results (Dict): Speed test results to log
        """
        try:
            with open(self.csv_filename, 'a', newline='') as csvfile:
                writer = csv.writer(csvfile)
                row = [results[header] for header in self.csv_headers]
                writer.writerow(row)
            self.logger.info(f"Results logged to {self.csv_filename}")
        except Exception as e:
            self.logger.error(f"Failed to write to CSV: {str(e)}")
    
    def run_continuous_test(self, interval_hours: int = 1) -> None:
        """
        Run speed tests continuously at specified intervals.
        
        Args:
            interval_hours (int): Hours between tests (default: 1)
        """
        interval_seconds = interval_hours * 3600
        self.logger.info(f"Starting continuous speed testing every {interval_hours} hour(s)")
        self.logger.info(f"Results will be saved to: {os.path.abspath(self.csv_filename)}")
        self.logger.info("Press Ctrl+C to stop")
        
        try:
            while True:
                # Perform speed test
                results = self.perform_speed_test()
                
                # Log results to CSV
                self.log_to_csv(results)
                
                # Wait for next test
                self.logger.info(f"Waiting {interval_hours} hour(s) until next test...")
                time.sleep(interval_seconds)
                
        except KeyboardInterrupt:
            self.logger.info("Speed testing stopped by user")
        except Exception as e:
            self.logger.error(f"Unexpected error: {str(e)}")
    
    def run_single_test(self) -> None:
        """Run a single speed test and log the results."""
        self.logger.info("Running single speed test...")
        results = self.perform_speed_test()
        self.log_to_csv(results)
        self.logger.info("Single test completed")


def main():
    """Main function to run the internet speed logger."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Internet Speed Logger")
    parser.add_argument(
        "--interval", 
        type=int, 
        default=1, 
        help="Hours between speed tests (default: 1)"
    )
    parser.add_argument(
        "--single", 
        action="store_true", 
        help="Run a single test instead of continuous testing"
    )
    parser.add_argument(
        "--output", 
        type=str, 
        default="internet_speed_log.csv", 
        help="Output CSV filename (default: internet_speed_log.csv)"
    )
    
    args = parser.parse_args()
    
    # Create logger instance
    logger = InternetSpeedLogger(csv_filename=args.output)
    
    if args.single:
        logger.run_single_test()
    else:
        logger.run_continuous_test(interval_hours=args.interval)


if __name__ == "__main__":
    main()