#!/bin/bash
#
# setup-cron.sh - Setup cron jobs for homelab tools
#
# Usage: ./setup-cron.sh
#

set -euo pipefail

echo "Setting up homelab cron jobs..."
echo ""

# Get current user's home directory
HOME_DIR="$HOME"
BIN_DIR="$HOME_DIR/bin"

# Check if scripts exist
if [[ ! -x "$BIN_DIR/network-scan-daemon" ]]; then
    echo "Error: $BIN_DIR/network-scan-daemon not found or not executable"
    echo "Please run install.sh first"
    exit 1
fi

# Define cron jobs
CRON_JOBS="
# Homelab Network Scanner - runs every 30 minutes
*/30 * * * * $BIN_DIR/network-scan-daemon >/dev/null 2>&1

# VOO Router Device Sync - runs hourly at :15
15 * * * * $BIN_DIR/voo-router-sync --update >/dev/null 2>&1
"

# Check if cron jobs already exist
EXISTING_CRON=$(crontab -l 2>/dev/null || echo "")

if echo "$EXISTING_CRON" | grep -q "network-scan-daemon"; then
    echo "⚠️  Network scan cron job already exists"
else
    echo "✓ Adding network-scan-daemon cron job (every 30 min)"
fi

if echo "$EXISTING_CRON" | grep -q "voo-router-sync"; then
    echo "⚠️  Router sync cron job already exists"
else
    echo "✓ Adding voo-router-sync cron job (hourly at :15)"
fi

# Prompt for confirmation
echo ""
read -p "Install cron jobs? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Remove existing homelab entries and add new ones
    (
        echo "$EXISTING_CRON" | grep -v "network-scan-daemon" | grep -v "voo-router-sync" | grep -v "^#.*Homelab"
        echo "$CRON_JOBS"
    ) | crontab -
    
    echo ""
    echo "✓ Cron jobs installed successfully!"
    echo ""
    echo "Current crontab:"
    crontab -l
else
    echo "Cancelled."
    exit 0
fi

echo ""
echo "To view cron jobs: crontab -l"
echo "To edit cron jobs: crontab -e"
echo "To remove all cron jobs: crontab -r"
