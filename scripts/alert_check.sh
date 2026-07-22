#!/bin/bash

set -Eeuo pipefail

SERVER_NAME="${SERVER_NAME:-Linux-Monitoring-Server}"
CPU_THRESHOLD="${CPU_THRESHOLD:-80}"
RAM_THRESHOLD="${RAM_THRESHOLD:-80}"
DISK_THRESHOLD="${DISK_THRESHOLD:-80}"
NETWORK_TARGET="${NETWORK_TARGET:-google.com}"
SERVICE_NAME="${SERVICE_NAME:-nginx}"

validate_threshold() {
    local name="$1"
    local value="$2"

    if ! [[ "$value" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo "ERROR: $name must be numeric. Received: $value" >&2
        exit 1
    fi
}

validate_threshold "CPU_THRESHOLD" "$CPU_THRESHOLD"
validate_threshold "RAM_THRESHOLD" "$RAM_THRESHOLD"
validate_threshold "DISK_THRESHOLD" "$DISK_THRESHOLD"

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

echo "===== ALERT CHECK ====="
echo "Server: $SERVER_NAME"
echo "Time: $TIMESTAMP"

CPU="$(top -bn1 | grep "Cpu(s)" | sed 's/,/ /g' | awk '{printf "%.1f", 100 - $8}')"
RAM="$(free | awk '/Mem:/ {printf "%.1f", $3/$2 * 100}')"
DISK="$(df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}')"

ALERT_FOUND=false

if (( $(echo "$CPU > $CPU_THRESHOLD" | bc -l) )); then
    echo "WARNING: High CPU Usage - $CPU%"
    ALERT_FOUND=true
fi

if (( $(echo "$RAM > $RAM_THRESHOLD" | bc -l) )); then
    echo "WARNING: High RAM Usage - $RAM%"
    ALERT_FOUND=true
fi

if (( $(echo "$DISK > $DISK_THRESHOLD" | bc -l) )); then
    echo "WARNING: High Disk Usage - $DISK%"
    ALERT_FOUND=true
fi

if ! ping -c 1 -W 2 "$NETWORK_TARGET" > /dev/null 2>&1; then
    echo "CRITICAL: Network Down"
    ALERT_FOUND=true
fi

if ! systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "CRITICAL: $SERVICE_NAME Stopped"
    ALERT_FOUND=true
fi

if [ "$ALERT_FOUND" = false ]; then
    echo "INFO: No Active Alerts"
fi

