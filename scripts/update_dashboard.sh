#!/bin/bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATUS_FILE="$PROJECT_DIR/dashboard/status.txt"
TEMP_FILE="$PROJECT_DIR/dashboard/.status.tmp"

SERVICE_NAME="${SERVICE_NAME:-nginx}"
NETWORK_TARGET="${NETWORK_TARGET:-google.com}"

CPU="$(top -bn1 | grep "Cpu(s)" | sed 's/,/ /g' | awk '{printf "%.1f", 100 - $8}')"
RAM="$(free | awk '/Mem:/ {printf "%.1f", $3/$2 * 100}')"
DISK="$(df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}')"

if ping -c 1 -W 2 "$NETWORK_TARGET" > /dev/null 2>&1; then
    NETWORK="Healthy"
else
    NETWORK="Warning"
fi

if systemctl is-active --quiet "$SERVICE_NAME"; then
    SERVICE_STATUS="Running"
else
    SERVICE_STATUS="Warning"
fi

{
    echo "CPU: $CPU%"
    echo "RAM: $RAM%"
    echo "Disk: $DISK%"
    echo "Network: $NETWORK"
    echo "$SERVICE_NAME: $SERVICE_STATUS"
    echo ""
    echo "Alerts:"
    "$PROJECT_DIR/scripts/alert_check.sh" | tail -n +2
} > "$TEMP_FILE"

mv "$TEMP_FILE" "$STATUS_FILE"

echo "Dashboard updated successfully: $STATUS_FILE"

