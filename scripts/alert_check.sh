#!/bin/bash

set -Eeuo pipefail

export LC_ALL=C

SERVER_NAME="${SERVER_NAME:-Linux-Monitoring-Server}"
CPU_THRESHOLD="${CPU_THRESHOLD:-80}"
RAM_THRESHOLD="${RAM_THRESHOLD:-80}"
DISK_THRESHOLD="${DISK_THRESHOLD:-80}"
NETWORK_TARGET="${NETWORK_TARGET:-google.com}"
SERVICE_NAME="${SERVICE_NAME:-nginx}"

validate_threshold() {
    local name="$1"
    local value="$2"

    if ! [[ "$value" =~ ^[0-9]+([.][0-9]+)?$ ]] ||
       ! LC_ALL=C awk -v value="$value" 'BEGIN {exit !(value >= 0 && value <= 100)}'; then
        echo "ERROR: $name must be numeric and within 0–100. Received: $value" >&2
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

CPU="${MONITOR_CPU:-$(top -bn2 -d 0.2 | awk '
/Cpu\(s\)/ {
    gsub(/,/, " ")
    for (i=2; i<=NF; i++) {
        if ($i == "id") {
            idle=$(i-1)
            found=1
        }
    }
}
END {
    if (!found || idle !~ /^[0-9]+([.][0-9]+)?$/ || idle < 0 || idle > 100)
        exit 1
    printf "%.1f", 100-idle
}')}"
RAM="${MONITOR_RAM:-$(free | awk '/Mem:/ {printf "%.1f", $3/$2 * 100}')}"
DISK="${MONITOR_DISK:-$(df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}')}"

# Reject malformed supplied snapshots before numeric comparisons.
for metric in CPU RAM DISK; do
    validate_threshold "MONITOR_$metric" "${!metric}"
done

ALERT_FOUND=false

if (( $(echo "$CPU >= $CPU_THRESHOLD" | bc -l) )); then
    echo "WARNING: High CPU Usage - $CPU%"
    ALERT_FOUND=true
fi

if (( $(echo "$RAM >= $RAM_THRESHOLD" | bc -l) )); then
    echo "WARNING: High RAM Usage - $RAM%"
    ALERT_FOUND=true
fi

if (( $(echo "$DISK >= $DISK_THRESHOLD" | bc -l) )); then
    echo "WARNING: High Disk Usage - $DISK%"
    ALERT_FOUND=true
fi

if ! ping -c 1 -W 2 "$NETWORK_TARGET" > /dev/null 2>&1; then
    echo "CRITICAL: Network Down"
    ALERT_FOUND=true
fi

if ! { if [ "$(ps -p 1 -o comm=)" = "systemd" ]; then
    systemctl is-active --quiet "$SERVICE_NAME"
else
    service "$SERVICE_NAME" status >/dev/null 2>&1
fi; }; then
    echo "CRITICAL: $SERVICE_NAME Stopped"
    ALERT_FOUND=true
fi

if [ "$ALERT_FOUND" = false ]; then
    echo "INFO: No Active Alerts"
fi

