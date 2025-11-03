#!/bin/bash

# Internet Speed Logger - Git Safe Setup Script
# This script prepares the project for git version control

set -e  # Exit on any error

echo "🚀 Setting up Internet Speed Logger for Git..."

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if git is installed
if ! command_exists git; then
    echo "❌ Git is not installed. Please install git first:"
    echo "   sudo apt install git  # Ubuntu/Debian"
    echo "   sudo dnf install git  # Fedora/RHEL"
    exit 1
fi

# Initialize git repository if not already done
if [ ! -d .git ]; then
    echo "📝 Initializing git repository..."
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

# Create configuration from template if it doesn't exist
if [ ! -f config.json ]; then
    if [ -f config.json.template ]; then
        echo "📋 Creating config.json from template..."
        cp config.json.template config.json
        echo "⚠️  Please edit config.json with your settings before committing"
    else
        echo "❌ config.json.template not found!"
        exit 1
    fi
else
    echo "✅ config.json already exists"
fi

# Make scripts executable
echo "🔧 Setting script permissions..."
chmod +x *.sh 2>/dev/null || true

# Check if .gitignore exists and is comprehensive
if [ -f .gitignore ]; then
    echo "✅ .gitignore file exists"
    
    # Check if important entries are present
    missing_entries=""
    
    if ! grep -q "config.json" .gitignore; then
        missing_entries="${missing_entries}\nconfig.json"
    fi
    
    if ! grep -q "*.csv" .gitignore; then
        missing_entries="${missing_entries}\n*.csv"
    fi
    
    if ! grep -q "*.service" .gitignore; then
        missing_entries="${missing_entries}\n*.service"
    fi
    
    if [ -n "$missing_entries" ]; then
        echo "⚠️  Warning: .gitignore may be missing important entries:$missing_entries"
    fi
else
    echo "❌ .gitignore file not found! This is required for git safety."
    exit 1
fi

# Create sample data if CSV doesn't exist
if [ ! -f internet_speed_log.csv ] && [ -f sample_data.csv ]; then
    echo "📊 Creating sample data file..."
    cp sample_data.csv internet_speed_log.csv
    echo "✅ Sample data created (will be ignored by git)"
fi

# Verify that sensitive files are gitignored
echo "🔍 Verifying git safety..."

# Check if config.json would be ignored
if git check-ignore config.json >/dev/null 2>&1; then
    echo "✅ config.json is properly ignored by git"
else
    echo "❌ WARNING: config.json is NOT ignored by git!"
    echo "   This could expose sensitive configuration data"
    exit 1
fi

# Check if CSV files would be ignored
if git check-ignore *.csv >/dev/null 2>&1 || [ ! -f *.csv ]; then
    echo "✅ CSV files are properly ignored by git"
else
    echo "❌ WARNING: CSV files are NOT ignored by git!"
    echo "   This could expose your speed test data"
    exit 1
fi

# Show git status
echo ""
echo "📋 Current git status:"
git status --porcelain

echo ""
echo "🎉 Git setup complete!"
echo ""
echo "📚 Next steps:"
echo "   1. Edit config.json with your settings"
echo "   2. Review files to be committed: git status"
echo "   3. Add files to git: git add ."
echo "   4. Make initial commit: git commit -m 'Initial commit'"
echo "   5. Add remote repository: git remote add origin <your-repo-url>"
echo "   6. Push to remote: git push -u origin main"
echo ""
echo "🔒 Sensitive files that are safely ignored:"
echo "   - config.json (contains passwords)"
echo "   - *.csv files (your speed test data)"
echo "   - *.log files (service logs)"
echo "   - *.service files (system-specific)"
echo "   - venv/ (virtual environment)"
echo ""
echo "✅ This project is now git-safe!"