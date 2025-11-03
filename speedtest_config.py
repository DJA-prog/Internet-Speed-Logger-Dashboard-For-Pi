#!/usr/bin/env python3
"""
Speedtest Configuration and Recommendations
Provides optimal settings to avoid rate limiting and blocking.
"""

import json
import os
from datetime import datetime, timedelta

class SpeedtestConfig:
    def __init__(self, config_file="speedtest_settings.json"):
        self.config_file = config_file
        self.default_config = {
            "test_interval": {
                "hours": 1.0,  # Test every hour (recommended)
                "min_interval": 0.25,  # Minimum 15 minutes between tests
                "max_daily_tests": 24  # Maximum tests per day
            },
            "retry_settings": {
                "max_retries": 3,
                "retry_delays": [30, 120, 300],  # Progressive delays in seconds
                "backoff_on_403": True,
                "backoff_multiplier": 2.0
            },
            "speedtest_options": {
                "timeout": 60,
                "use_secure": True,
                "use_single_connection": True,
                "preferred_servers": [],  # Empty = auto-select
                "exclude_servers": []
            },
            "rate_limiting": {
                "adaptive_interval": True,  # Increase interval on repeated failures
                "error_threshold": 3,  # Failures before increasing interval
                "cooldown_hours": 2.0,  # Extended wait after repeated failures
                "reset_success_count": 5  # Successful tests to reset interval
            },
            "logging": {
                "log_level": "INFO",
                "detailed_errors": True,
                "track_server_performance": True
            }
        }
        self.load_config()
    
    def load_config(self):
        """Load configuration from file or create default."""
        try:
            if os.path.exists(self.config_file):
                with open(self.config_file, 'r') as f:
                    self.config = json.load(f)
                # Merge with defaults for missing keys
                self._merge_defaults()
            else:
                self.config = self.default_config.copy()
                self.save_config()
        except Exception as e:
            print(f"Error loading config: {e}. Using defaults.")
            self.config = self.default_config.copy()
    
    def save_config(self):
        """Save current configuration to file."""
        try:
            with open(self.config_file, 'w') as f:
                json.dump(self.config, f, indent=2)
            return True
        except Exception as e:
            print(f"Error saving config: {e}")
            return False
    
    def _merge_defaults(self):
        """Merge loaded config with defaults for missing keys."""
        def merge_dict(default, loaded):
            for key, value in default.items():
                if key not in loaded:
                    loaded[key] = value
                elif isinstance(value, dict) and isinstance(loaded[key], dict):
                    merge_dict(value, loaded[key])
        
        merge_dict(self.default_config, self.config)
    
    def get_optimal_interval(self):
        """Get the optimal test interval based on current settings and history."""
        base_interval = self.config["test_interval"]["hours"]
        
        if self.config["rate_limiting"]["adaptive_interval"]:
            # Check recent failure history
            failure_count = self._get_recent_failures()
            if failure_count >= self.config["rate_limiting"]["error_threshold"]:
                # Increase interval after repeated failures
                multiplier = self.config["rate_limiting"]["backoff_multiplier"]
                adapted_interval = base_interval * (multiplier ** (failure_count - 2))
                max_interval = 6.0  # Cap at 6 hours
                return min(adapted_interval, max_interval)
        
        return base_interval
    
    def _get_recent_failures(self):
        """Count recent failures (would need to be implemented with actual failure tracking)."""
        # This would integrate with your logging system
        # For now, return 0 (no failures)
        return 0
    
    def get_speedtest_command(self):
        """Generate optimized speedtest command."""
        cmd = ['speedtest-cli', '--json']
        
        opts = self.config["speedtest_options"]
        
        if opts["timeout"]:
            cmd.extend(['--timeout', str(opts["timeout"])])
        
        if opts["use_secure"]:
            cmd.append('--secure')
        
        if opts["use_single_connection"]:
            cmd.append('--single')
        
        if opts["preferred_servers"]:
            for server in opts["preferred_servers"]:
                cmd.extend(['--server', str(server)])
        
        return cmd
    
    def should_test_now(self, last_test_time=None):
        """Determine if enough time has passed for next test."""
        if not last_test_time:
            return True
        
        if isinstance(last_test_time, str):
            last_test_time = datetime.fromisoformat(last_test_time)
        
        interval_hours = self.get_optimal_interval()
        min_interval = timedelta(hours=interval_hours)
        
        return datetime.now() - last_test_time >= min_interval
    
    def get_recommendations(self):
        """Get current recommendations for optimal speedtest usage."""
        interval = self.get_optimal_interval()
        daily_tests = 24 / interval
        
        return {
            "current_interval_hours": interval,
            "estimated_daily_tests": round(daily_tests, 1),
            "recommendations": [
                f"Testing every {interval} hours ({daily_tests:.1f} tests/day)",
                "Using secure HTTPS connections",
                "Single connection mode to reduce server load",
                "Automatic retry with progressive delays",
                "Adaptive interval on repeated failures"
            ],
            "rate_limit_protection": [
                "Progressive retry delays: 30s, 2m, 5m",
                "Automatic backoff on 403 errors",
                "Adaptive interval increases after failures",
                "Maximum daily test limit protection"
            ]
        }

def print_recommendations():
    """Print current speedtest recommendations."""
    config = SpeedtestConfig()
    recs = config.get_recommendations()
    
    print("🚀 SPEEDTEST OPTIMIZATION RECOMMENDATIONS")
    print("=" * 50)
    print(f"Current interval: {recs['current_interval_hours']} hours")
    print(f"Daily tests: ~{recs['estimated_daily_tests']}")
    print()
    print("✅ Current Settings:")
    for rec in recs['recommendations']:
        print(f"  • {rec}")
    print()
    print("🛡️  Rate Limit Protection:")
    for protection in recs['rate_limit_protection']:
        print(f"  • {protection}")
    print()
    print("💡 Tips to Avoid Blocking:")
    print("  • Test during off-peak hours (2-6 AM local)")
    print("  • Use different servers occasionally")
    print("  • Monitor for 403 errors and back off")
    print("  • Consider 2-hour intervals for very stable monitoring")
    print("  • Keep tests under 50 per day total")

if __name__ == "__main__":
    print_recommendations()