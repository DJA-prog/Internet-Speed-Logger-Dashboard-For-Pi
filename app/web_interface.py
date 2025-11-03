#!/usr/bin/env python3
"""
Internet Speed Logger Web Interface
A Flask web application for viewing speed test results with charts and CSV download.
"""

import os
import csv
import json
import hashlib
from datetime import datetime, timedelta
from flask import Flask, render_template, jsonify, send_file, request, redirect, url_for, flash, session
import pandas as pd
import logging

app = Flask(__name__)
app.config['SECRET_KEY'] = 'internet-speed-logger-2025'
app.config['DEBUG'] = True  # Use FLASK_DEBUG instead of FLASK_ENV
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=24)  # 24 hour session
app.config['SESSION_COOKIE_SECURE'] = False  # Set to True if using HTTPS
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration
CSV_FILE = os.environ.get('CSV_FILE', 'internet_speed_log.csv')
CONFIG_FILE = os.environ.get('CONFIG_FILE', 'config.json')
DATA_DIR = os.path.dirname(os.path.abspath(__file__))

# Use environment variables for paths if available
if os.environ.get('CSV_FILE'):
    CSV_PATH = os.environ.get('CSV_FILE')
else:
    CSV_PATH = os.path.join(DATA_DIR, CSV_FILE)

if os.environ.get('CONFIG_FILE'):
    CONFIG_PATH = os.environ.get('CONFIG_FILE')
else:
    CONFIG_PATH = os.path.join(DATA_DIR, CONFIG_FILE)

# Default admin credentials (change these!)
DEFAULT_ADMIN_USERNAME = 'admin'
DEFAULT_ADMIN_PASSWORD = 'speedtest123'  # This will be hashed

def load_config():
    """Load configuration from JSON file."""
    default_config = {
        'admin': {
            'username': DEFAULT_ADMIN_USERNAME,
            'password_hash': hashlib.sha256(DEFAULT_ADMIN_PASSWORD.encode()).hexdigest()
        },
        'subscription_package': {
            'name': 'Internet Package',
            'download': 100,
            'upload': 20
        },
        'test_settings': {
            'interval_hours': 1,
            'manual_cooldown_minutes': 15,
            'last_updated': None,
            'last_manual_test': None
        }
    }
    
    try:
        if os.path.exists(CONFIG_PATH):
            with open(CONFIG_PATH, 'r') as f:
                config = json.load(f)
            # Merge with defaults for any missing keys
            for key in default_config:
                if key not in config:
                    config[key] = default_config[key]
            return config
        else:
            save_config(default_config)
            return default_config
    except Exception as e:
        logger.error(f"Error loading config: {e}")
        return default_config

def save_config(config):
    """Save configuration to JSON file."""
    try:
        with open(CONFIG_PATH, 'w') as f:
            json.dump(config, f, indent=2)
        return True
    except Exception as e:
        logger.error(f"Error saving config: {e}")
        return False

def verify_admin_credentials(username, password):
    """Verify admin login credentials."""
    config = load_config()
    password_hash = hashlib.sha256(password.encode()).hexdigest()
    return (username == config['admin']['username'] and 
            password_hash == config['admin']['password_hash'])

def require_admin_login(f):
    """Decorator to require admin login for routes."""
    def decorated_function(*args, **kwargs):
        if not session.get('admin_logged_in'):
            return redirect(url_for('admin_login'))
        return f(*args, **kwargs)
    decorated_function.__name__ = f.__name__
    return decorated_function

def read_speed_data():
    """Read speed test data from CSV file."""
    try:
        if not os.path.exists(CSV_PATH):
            return []
        
        data = []
        with open(CSV_PATH, 'r') as file:
            reader = csv.DictReader(file)
            for row in reader:
                # Skip error rows
                if row['download_speed_mbps'] == 'ERROR':
                    continue
                
                try:
                    # Parse and validate data
                    entry = {
                        'timestamp': row['timestamp'],
                        'download_speed_mbps': float(row['download_speed_mbps']),
                        'upload_speed_mbps': float(row['upload_speed_mbps']),
                        'ping_ms': float(row['ping_ms'])
                    }
                    
                    # Add additional fields if they exist
                    if 'server_name' in row:
                        entry['server_name'] = row['server_name']
                    if 'server_country' in row:
                        entry['server_country'] = row['server_country']
                    if 'isp' in row:
                        entry['isp'] = row['isp']
                    
                    data.append(entry)
                except (ValueError, KeyError) as e:
                    logger.warning(f"Skipping invalid row: {row}, error: {e}")
                    continue
        
        # Sort by timestamp
        data.sort(key=lambda x: x['timestamp'])
        return data
    
    except Exception as e:
        logger.error(f"Error reading CSV file: {e}")
        return []

def get_recent_test_attempts(limit=5):
    """Get recent test attempts from systemd journal logs."""
    import subprocess
    import re
    from datetime import datetime, timedelta
    
    try:
        # Get recent logs from the internet-speed-logger service
        since_time = (datetime.now() - timedelta(hours=24)).strftime('%Y-%m-%d %H:%M:%S')
        
        cmd = [
            'journalctl', 
            '-u', 'internet-speed-logger.service',
            '--since', since_time,
            '--no-pager',
            '-o', 'short-iso'
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        
        if result.returncode != 0:
            logger.warning(f"Failed to get journal logs: {result.stderr}")
            return []
        
        attempts = []
        lines = result.stdout.strip().split('\n')
        
        for line in lines:
            # Parse log entries for speed test attempts
            if 'Starting speed test...' in line:
                match = re.match(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{4})', line)
                if match:
                    timestamp = match.group(1)
                    attempts.append({
                        'timestamp': timestamp,
                        'status': 'started',
                        'message': 'Speed test started',
                        'type': 'info'
                    })
            
            elif 'Speed test completed:' in line:
                match = re.match(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{4})', line)
                if match:
                    timestamp = match.group(1)
                    # Extract speed info
                    speed_match = re.search(r'(\d+\.?\d*) Mbps down, (\d+\.?\d*) Mbps up, (\d+\.?\d*) ms ping', line)
                    if speed_match:
                        message = f"Success: {speed_match.group(1)} Mbps down, {speed_match.group(2)} Mbps up, {speed_match.group(3)} ms ping"
                    else:
                        message = "Speed test completed successfully"
                    
                    attempts.append({
                        'timestamp': timestamp,
                        'status': 'success',
                        'message': message,
                        'type': 'success'
                    })
            
            elif 'Speed test failed:' in line:
                match = re.match(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{4})', line)
                if match:
                    timestamp = match.group(1)
                    # Extract error message
                    error_match = re.search(r'Speed test failed: (.+)', line)
                    if error_match:
                        message = f"Failed: {error_match.group(1)}"
                    else:
                        message = "Speed test failed"
                    
                    attempts.append({
                        'timestamp': timestamp,
                        'status': 'failed',
                        'message': message,
                        'type': 'error'
                    })
            
            elif 'ERROR: HTTP Error 403: Forbidden' in line:
                match = re.match(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{4})', line)
                if match:
                    timestamp = match.group(1)
                    attempts.append({
                        'timestamp': timestamp,
                        'status': 'failed',
                        'message': 'Failed: HTTP Error 403 - Speedtest server blocked request',
                        'type': 'error'
                    })
            
            elif 'Failed to write to CSV:' in line:
                match = re.match(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{4})', line)
                if match:
                    timestamp = match.group(1)
                    attempts.append({
                        'timestamp': timestamp,
                        'status': 'warning',
                        'message': 'Warning: Failed to write results to CSV file',
                        'type': 'warning'
                    })
        
        # Sort by timestamp (newest first) and limit results
        attempts.sort(key=lambda x: x['timestamp'], reverse=True)
        
        # Convert timestamps to more readable format
        for attempt in attempts[:limit]:
            try:
                dt = datetime.fromisoformat(attempt['timestamp'].replace('Z', '+00:00'))
                attempt['timestamp_readable'] = dt.strftime('%Y-%m-%d %H:%M:%S')
                attempt['timestamp_relative'] = get_relative_time(dt)
            except:
                attempt['timestamp_readable'] = attempt['timestamp']
                attempt['timestamp_relative'] = 'Unknown'
        
        return attempts[:limit]
        
    except Exception as e:
        logger.error(f"Error getting recent test attempts: {e}")
        return []

def get_relative_time(dt):
    """Get relative time string (e.g., '2 minutes ago')."""
    try:
        now = datetime.now(dt.tzinfo) if dt.tzinfo else datetime.now()
        diff = now - dt
        
        if diff.total_seconds() < 60:
            return "Just now"
        elif diff.total_seconds() < 3600:
            minutes = int(diff.total_seconds() / 60)
            return f"{minutes} minute{'s' if minutes != 1 else ''} ago"
        elif diff.total_seconds() < 86400:
            hours = int(diff.total_seconds() / 3600)
            return f"{hours} hour{'s' if hours != 1 else ''} ago"
        else:
            days = diff.days
            return f"{days} day{'s' if days != 1 else ''} ago"
    except:
        return "Unknown"

def get_statistics(data):
    """Calculate statistics from speed data."""
    if not data:
        return {}
    
    downloads = [entry['download_speed_mbps'] for entry in data]
    uploads = [entry['upload_speed_mbps'] for entry in data]
    pings = [entry['ping_ms'] for entry in data]
    
    stats = {
        'total_tests': len(data),
        'download': {
            'avg': round(sum(downloads) / len(downloads), 2),
            'min': round(min(downloads), 2),
            'max': round(max(downloads), 2)
        },
        'upload': {
            'avg': round(sum(uploads) / len(uploads), 2),
            'min': round(min(uploads), 2),
            'max': round(max(uploads), 2)
        },
        'ping': {
            'avg': round(sum(pings) / len(pings), 2),
            'min': round(min(pings), 2),
            'max': round(max(pings), 2)
        }
    }
    
    if data:
        stats['first_test'] = data[0]['timestamp']
        stats['last_test'] = data[-1]['timestamp']
    
    return stats

@app.route('/')
def dashboard():
    """Main dashboard page."""
    data = read_speed_data()
    stats = get_statistics(data)
    config = load_config()
    
    # Check manual test availability
    can_test, cooldown_remaining = can_run_manual_test()
    
    return render_template('dashboard.html', 
                         stats=stats, 
                         total_tests=len(data),
                         package=config['subscription_package'],
                         can_manual_test=can_test,
                         manual_test_cooldown=cooldown_remaining)

@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    """Admin login page."""
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        if verify_admin_credentials(username, password):
            session['admin_logged_in'] = True
            session['admin_username'] = username
            session.permanent = True  # Make session persistent
            flash('Successfully logged in as administrator', 'success')
            return redirect(url_for('admin_dashboard'))
        else:
            flash('Invalid username or password', 'error')
    
    return render_template('admin_login.html')

@app.route('/admin/logout')
def admin_logout():
    """Admin logout."""
    session.pop('admin_logged_in', None)
    session.pop('admin_username', None)
    flash('Successfully logged out', 'info')
    return redirect(url_for('dashboard'))

@app.route('/admin')
@require_admin_login
def admin_dashboard():
    """Admin dashboard page."""
    config = load_config()
    data = read_speed_data()
    stats = get_statistics(data)
    
    return render_template('admin_dashboard.html',
                         config=config,
                         stats=stats,
                         total_tests=len(data))

@app.route('/admin/update-packages', methods=['POST'])
@require_admin_login
def update_packages():
    """Update subscription package."""
    try:
        config = load_config()
        
        config['subscription_package'] = {
            'name': request.form['package_name'],
            'download': float(request.form['package_download']),
            'upload': float(request.form['package_upload'])
        }
        
        # Update manual test cooldown if provided
        if 'manual_test_cooldown' in request.form:
            if 'test_settings' not in config:
                config['test_settings'] = {}
            config['test_settings']['manual_cooldown_minutes'] = int(request.form['manual_test_cooldown'])
        
        if save_config(config):
            flash('Subscription package updated successfully', 'success')
        else:
            flash('Error saving configuration', 'error')
            
    except Exception as e:
        flash(f'Error updating package: {str(e)}', 'error')
    
    return redirect(url_for('admin_dashboard'))

@app.route('/admin/update-settings', methods=['POST'])
@require_admin_login
def update_settings():
    """Update test settings."""
    try:
        config = load_config()
        
        new_interval = float(request.form['interval_hours'])
        new_cooldown = int(request.form['manual_cooldown_minutes'])
        
        # Validate interval
        if new_interval < 0.1 or new_interval > 24:
            flash('Test interval must be between 0.1 and 24 hours', 'error')
            return redirect(url_for('admin_dashboard'))
        
        # Validate cooldown
        if new_cooldown < 1 or new_cooldown > 1440:
            flash('Manual test cooldown must be between 1 and 1440 minutes (24 hours)', 'error')
            return redirect(url_for('admin_dashboard'))
        
        old_interval = config['test_settings']['interval_hours']
        config['test_settings']['interval_hours'] = new_interval
        config['test_settings']['manual_cooldown_minutes'] = new_cooldown
        config['test_settings']['last_updated'] = datetime.now().isoformat()
        
        if save_config(config):
            # Only update service if interval actually changed
            if old_interval != new_interval:
                if update_service_interval(new_interval):
                    flash(f'Settings updated successfully. Test interval: {new_interval}h, Manual cooldown: {new_cooldown}min. Service restarted.', 'success')
                else:
                    flash(f'Configuration saved but failed to restart service. Please restart manually.', 'warning')
            else:
                flash(f'Settings updated successfully. Manual test cooldown: {new_cooldown} minutes.', 'success')
        else:
            flash('Error saving configuration', 'error')
            
    except ValueError:
        flash('Invalid values. Please enter valid numbers.', 'error')
    except Exception as e:
        flash(f'Error updating settings: {str(e)}', 'error')
    
    return redirect(url_for('admin_dashboard'))

@app.route('/admin/change-password', methods=['POST'])
@require_admin_login
def change_password():
    """Change admin password."""
    try:
        current_password = request.form['current_password']
        new_password = request.form['new_password']
        confirm_password = request.form['confirm_password']
        
        config = load_config()
        
        # Verify current password
        if not verify_admin_credentials(config['admin']['username'], current_password):
            flash('Current password is incorrect', 'error')
            return redirect(url_for('admin_dashboard'))
        
        # Check new password confirmation
        if new_password != confirm_password:
            flash('New passwords do not match', 'error')
            return redirect(url_for('admin_dashboard'))
        
        # Update password
        config['admin']['password_hash'] = hashlib.sha256(new_password.encode()).hexdigest()
        
        if save_config(config):
            flash('Password changed successfully', 'success')
        else:
            flash('Error saving new password', 'error')
            
    except Exception as e:
        flash(f'Error changing password: {str(e)}', 'error')
    
    return redirect(url_for('admin_dashboard'))

@app.route('/api/manual-test', methods=['POST'])
def api_manual_test():
    """API endpoint to trigger manual speed test."""
    try:
        can_test, cooldown_remaining = can_run_manual_test()
        
        if not can_test:
            return jsonify({
                'success': False,
                'message': f'Please wait {cooldown_remaining} more minutes before running another test'
            }), 429
        
        # Run the test in background
        import threading
        
        def run_test():
            success, message = run_manual_speed_test()
            logger.info(f"Manual test result: {success}, {message}")
        
        test_thread = threading.Thread(target=run_test)
        test_thread.daemon = True
        test_thread.start()
        
        return jsonify({
            'success': True,
            'message': 'Speed test started. Results will appear in the dashboard shortly.'
        })
        
    except Exception as e:
        logger.error(f"Error triggering manual test: {e}")
        return jsonify({
            'success': False,
            'message': f'Error starting speed test: {str(e)}'
        }), 500

@app.route('/api/manual-test-status')
def api_manual_test_status():
    """API endpoint to check manual test availability."""
    try:
        can_test, cooldown_remaining = can_run_manual_test()
        config = load_config()
        
        return jsonify({
            'can_test': can_test,
            'cooldown_remaining': cooldown_remaining,
            'cooldown_minutes': config['test_settings'].get('manual_cooldown_minutes', 15),
            'last_manual_test': config['test_settings'].get('last_manual_test')
        })
        
    except Exception as e:
        logger.error(f"Error checking manual test status: {e}")
        return jsonify({
            'can_test': False,
            'cooldown_remaining': 0,
            'error': str(e)
        }), 500

def update_service_interval(new_interval_hours):
    """Update the systemd service with new interval."""
    try:
        import subprocess
        
        # Use the dedicated update script
        update_script = os.path.join(DATA_DIR, 'update_interval.sh')
        
        if os.path.exists(update_script):
            result = subprocess.run([update_script, str(new_interval_hours)], 
                                  capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                logger.info(f"Service interval updated successfully to {new_interval_hours} hours")
                logger.info(f"Update output: {result.stdout}")
                return True
            else:
                logger.error(f"Failed to update service interval: {result.stderr}")
                return False
        else:
            logger.error(f"Update script not found: {update_script}")
            return False
        
    except subprocess.TimeoutExpired:
        logger.error("Service update timed out")
        return False
    except Exception as e:
        logger.error(f"Error updating service interval: {e}")
        return False

def can_run_manual_test():
    """Check if manual test can be run based on cooldown period."""
    config = load_config()
    last_manual_test = config['test_settings'].get('last_manual_test')
    cooldown_minutes = config['test_settings'].get('manual_cooldown_minutes', 15)
    
    if not last_manual_test:
        return True, 0
    
    try:
        last_test_time = datetime.fromisoformat(last_manual_test)
        cooldown_period = timedelta(minutes=cooldown_minutes)
        time_since_last = datetime.now() - last_test_time
        
        if time_since_last >= cooldown_period:
            return True, 0
        else:
            remaining_minutes = (cooldown_period - time_since_last).total_seconds() / 60
            return False, int(remaining_minutes) + 1
    except Exception as e:
        logger.error(f"Error checking manual test cooldown: {e}")
        return True, 0

def run_manual_speed_test():
    """Execute a manual speed test."""
    try:
        import subprocess
        import tempfile
        
        # Create a temporary script to run the speed test
        manual_test_script = """#!/bin/bash
cd /home/user01/Desktop/internet_speed_logger
python3 simple_speed_logger.py 0 2>&1
"""
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as f:
            f.write(manual_test_script)
            script_path = f.name
        
        # Make script executable
        subprocess.run(['chmod', '+x', script_path])
        
        # Run the test with timeout
        result = subprocess.run([script_path], capture_output=True, text=True, timeout=120)
        
        # Clean up
        subprocess.run(['rm', '-f', script_path])
        
        # Update last manual test time
        config = load_config()
        config['test_settings']['last_manual_test'] = datetime.now().isoformat()
        save_config(config)
        
        if result.returncode == 0:
            logger.info("Manual speed test completed successfully")
            return True, "Speed test completed successfully"
        else:
            logger.error(f"Manual speed test failed: {result.stderr}")
            return False, f"Speed test failed: {result.stderr}"
            
    except subprocess.TimeoutExpired:
        return False, "Speed test timed out (took longer than 2 minutes)"
    except Exception as e:
        logger.error(f"Error running manual speed test: {e}")
        return False, f"Error running speed test: {str(e)}"

def get_package_performance(data, package):
    """Analyze performance against subscription package."""
    if not data or not package:
        return {}
    
    download_target = package['download']
    upload_target = package['upload']
    
    download_meets = sum(1 for entry in data if entry['download_speed_mbps'] >= download_target)
    upload_meets = sum(1 for entry in data if entry['upload_speed_mbps'] >= upload_target)
    
    total_tests = len(data)
    
    performance = {
        'name': package['name'],
        'download_target': download_target,
        'upload_target': upload_target,
        'download_success_rate': round((download_meets / total_tests) * 100, 1) if total_tests > 0 else 0,
        'upload_success_rate': round((upload_meets / total_tests) * 100, 1) if total_tests > 0 else 0,
        'overall_success_rate': round(((download_meets + upload_meets) / (total_tests * 2)) * 100, 1) if total_tests > 0 else 0
    }
    
    return performance

@app.route('/api/data')
def api_data():
    """API endpoint to get speed test data as JSON."""
    data = read_speed_data()
    config = load_config()
    
    # Get query parameters for filtering
    days = request.args.get('days', type=int)
    limit = request.args.get('limit', type=int)
    
    # Filter by days if specified
    if days:
        cutoff_date = datetime.now() - timedelta(days=days)
        data = [entry for entry in data 
                if datetime.strptime(entry['timestamp'], '%Y-%m-%d %H:%M:%S') >= cutoff_date]
    
    # Limit results if specified
    if limit:
        data = data[-limit:]
    
    # Calculate package performance
    package_performance = get_package_performance(data, config['subscription_package'])
    
    # Check manual test status
    can_test, cooldown_remaining = can_run_manual_test()
    
    return jsonify({
        'data': data,
        'stats': get_statistics(data),
        'package_performance': package_performance,
        'manual_test': {
            'can_test': can_test,
            'cooldown_remaining': cooldown_remaining
        },
        'config': {
            'package': config['subscription_package'],
            'test_interval': config['test_settings']['interval_hours'],
            'manual_cooldown': config['test_settings'].get('manual_cooldown_minutes', 15)
        }
    })

@app.route('/api/chart-data')
def api_chart_data():
    """API endpoint optimized for chart display."""
    data = read_speed_data()
    
    # Get query parameters
    days = request.args.get('days', default=7, type=int)
    
    # Filter by days
    cutoff_date = datetime.now() - timedelta(days=days)
    filtered_data = [entry for entry in data 
                    if datetime.strptime(entry['timestamp'], '%Y-%m-%d %H:%M:%S') >= cutoff_date]
    
    # Prepare data for charts
    chart_data = {
        'labels': [entry['timestamp'] for entry in filtered_data],
        'download_speeds': [entry['download_speed_mbps'] for entry in filtered_data],
        'upload_speeds': [entry['upload_speed_mbps'] for entry in filtered_data],
        'ping_times': [entry['ping_ms'] for entry in filtered_data]
    }
    
    return jsonify(chart_data)

@app.route('/download/csv')
def download_csv():
    """Download the complete CSV file."""
    try:
        if not os.path.exists(CSV_PATH):
            return "CSV file not found", 404
        
        return send_file(
            CSV_PATH,
            as_attachment=True,
            download_name=f'internet_speed_log_{datetime.now().strftime("%Y%m%d_%H%M%S")}.csv',
            mimetype='text/csv'
        )
    except Exception as e:
        logger.error(f"Error downloading CSV: {e}")
        return f"Error downloading file: {e}", 500

@app.route('/download/filtered-csv')
def download_filtered_csv():
    """Download filtered CSV data based on query parameters."""
    try:
        data = read_speed_data()
        
        # Get query parameters for filtering
        days = request.args.get('days', type=int)
        
        # Filter by days if specified
        if days:
            cutoff_date = datetime.now() - timedelta(days=days)
            data = [entry for entry in data 
                    if datetime.strptime(entry['timestamp'], '%Y-%m-%d %H:%M:%S') >= cutoff_date]
        
        if not data:
            return "No data available for the specified filter", 404
        
        # Create temporary CSV file
        import tempfile
        temp_file = tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.csv')
        
        # Write headers
        fieldnames = ['timestamp', 'download_speed_mbps', 'upload_speed_mbps', 'ping_ms']
        if data and 'server_name' in data[0]:
            fieldnames.extend(['server_name', 'server_country', 'isp'])
        
        writer = csv.DictWriter(temp_file, fieldnames=fieldnames)
        writer.writeheader()
        
        # Write data
        for entry in data:
            row = {key: entry.get(key, '') for key in fieldnames}
            writer.writerow(row)
        
        temp_file.close()
        
        # Generate filename
        suffix = f"_{days}days" if days else "_all"
        filename = f'internet_speed_log{suffix}_{datetime.now().strftime("%Y%m%d_%H%M%S")}.csv'
        
        return send_file(
            temp_file.name,
            as_attachment=True,
            download_name=filename,
            mimetype='text/csv'
        )
    
    except Exception as e:
        logger.error(f"Error creating filtered CSV: {e}")
        return f"Error creating file: {e}", 500

@app.route('/api/status')
def api_status():
    """API endpoint to get system status."""
    try:
        # Check if CSV file exists and get basic info
        if os.path.exists(CSV_PATH):
            stat_info = os.stat(CSV_PATH)
            last_modified = datetime.fromtimestamp(stat_info.st_mtime)
            file_size = stat_info.st_size
        else:
            last_modified = None
            file_size = 0
        
        data = read_speed_data()
        
        status = {
            'csv_exists': os.path.exists(CSV_PATH),
            'csv_last_modified': last_modified.isoformat() if last_modified else None,
            'csv_file_size': file_size,
            'total_records': len(data),
            'latest_test': data[-1]['timestamp'] if data else None,
            'server_time': datetime.now().isoformat()
        }
        
        return jsonify(status)
    
    except Exception as e:
        logger.error(f"Error getting status: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/recent-attempts')
def api_recent_attempts():
    """API endpoint to get recent test attempts from service logs."""
    try:
        attempts = get_recent_test_attempts(limit=5)
        
        # Also check service status
        import subprocess
        try:
            service_status = subprocess.run(
                ['systemctl', 'is-active', 'internet-speed-logger.service'],
                capture_output=True, text=True, timeout=5
            )
            is_running = service_status.stdout.strip() == 'active'
        except:
            is_running = False
        
        return jsonify({
            'recent_attempts': attempts,
            'service_running': is_running,
            'last_updated': datetime.now().isoformat()
        })
    
    except Exception as e:
        logger.error(f"Error getting recent attempts: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health_check():
    """Health check endpoint for Docker and monitoring."""
    try:
        # Check basic application health
        health_status = {
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'checks': {}
        }
        
        # Check if config file exists and is readable
        try:
            config = load_config()
            health_status['checks']['config'] = 'ok'
        except Exception as e:
            health_status['checks']['config'] = f'error: {str(e)}'
            health_status['status'] = 'unhealthy'
        
        # Check if CSV directory is writable
        try:
            csv_dir = os.path.dirname(CSV_PATH)
            if os.path.exists(csv_dir) and os.access(csv_dir, os.W_OK):
                health_status['checks']['csv_writable'] = 'ok'
            else:
                health_status['checks']['csv_writable'] = 'error: directory not writable'
                health_status['status'] = 'unhealthy'
        except Exception as e:
            health_status['checks']['csv_writable'] = f'error: {str(e)}'
            health_status['status'] = 'unhealthy'
        
        # Check if we can read speed data
        try:
            data = read_speed_data()
            health_status['checks']['data_access'] = 'ok'
            health_status['checks']['total_records'] = len(data)
        except Exception as e:
            health_status['checks']['data_access'] = f'error: {str(e)}'
            health_status['status'] = 'unhealthy'
        
        # Return appropriate HTTP status code
        status_code = 200 if health_status['status'] == 'healthy' else 503
        return jsonify(health_status), status_code
        
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 503

if __name__ == '__main__':
    # Development server
    app.run(host='0.0.0.0', port=5000, debug=True)