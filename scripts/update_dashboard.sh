#!/bin/bash

set -Eeuo pipefail

export LC_ALL=C

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATUS_FILE="$PROJECT_DIR/dashboard/status.txt"

SERVICE_NAME="${SERVICE_NAME:-nginx}"
NETWORK_TARGET="${NETWORK_TARGET:-google.com}"

CPU="$(top -bn2 -d 0.2 | awk '
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
}')"
RAM="$(free | awk '/Mem:/ {printf "%.1f", $3/$2 * 100}')"
DISK="$(df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}')"

if ping -c 1 -W 2 "$NETWORK_TARGET" > /dev/null 2>&1; then
    NETWORK="Healthy"
else
    NETWORK="Warning"
fi

if { if [ "$(ps -p 1 -o comm=)" = "systemd" ]; then
    systemctl is-active --quiet "$SERVICE_NAME"
else
    service "$SERVICE_NAME" status >/dev/null 2>&1
fi; }; then
    SERVICE_STATUS="Running"
else
    SERVICE_STATUS="Warning"
fi

TEMP_FILE="$(mktemp "$PROJECT_DIR/dashboard/.status.XXXXXX")"
trap 'rm -f -- "$TEMP_FILE"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

{
    echo "CPU: $CPU%"
    echo "RAM: $RAM%"
    echo "Disk: $DISK%"
    echo "Network: $NETWORK"
    echo "$SERVICE_NAME: $SERVICE_STATUS"
    echo ""
    echo "Alerts:"
    MONITOR_CPU="$CPU" MONITOR_RAM="$RAM" MONITOR_DISK="$DISK" "$PROJECT_DIR/scripts/alert_check.sh" | tail -n +2
} > "$TEMP_FILE"

chmod 644 "$TEMP_FILE"
mv "$TEMP_FILE" "$STATUS_FILE"

echo "Dashboard updated successfully: $STATUS_FILE"

