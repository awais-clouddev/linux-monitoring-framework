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
    found=0
    idle=""
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
RAM="${MONITOR_RAM:-$(free | awk '
$1 == "Mem:" {
    count++
    if (NF < 3 || $2 !~ /^[0-9]+$/ || $3 !~ /^[0-9]+$/ ||
        $2 <= 0 || $3 < 0 || $3 > $2) {
        invalid=1
    } else {
        usage=$3/$2*100
    }
}
END {
    if (count != 1 || invalid) {
        print "ERROR: Invalid RAM total/used fields" > "/dev/stderr"
        exit 1
    }
    printf "%.1f", usage
}')}"
DISK="${MONITOR_DISK:-$(df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}')}"

# Reject malformed supplied snapshots before numeric comparisons.
for metric in CPU RAM DISK; do
    validate_threshold "MONITOR_$metric" "${!metric}"
done

if [[ ! -v MONITOR_NETWORK ]]; then
    if ping -c 1 -W 2 "$NETWORK_TARGET" >/dev/null 2>&1; then
        MONITOR_NETWORK=Healthy
    else
        MONITOR_NETWORK=Warning
    fi
fi
case "$MONITOR_NETWORK" in
    Healthy|Warning) ;;
    *) echo "ERROR: Invalid network snapshot" >&2; exit 1 ;;
esac

if [[ ! -v MONITOR_SERVICE ]]; then
    if { if [ "$(ps -p 1 -o comm=)" = "systemd" ]; then
    systemctl is-active --quiet "$SERVICE_NAME"
else
    service "$SERVICE_NAME" status >/dev/null 2>&1
fi; }; then
        MONITOR_SERVICE=Running
    else
        MONITOR_SERVICE=Warning
    fi
fi
case "$MONITOR_SERVICE" in
    Running|Warning) ;;
    *) echo "ERROR: Invalid service snapshot" >&2; exit 1 ;;
esac

ALERT_FOUND=false

COMPARISON="$(LC_ALL=C awk -v value="$CPU" -v threshold="$CPU_THRESHOLD" '
BEGIN {
    if (value !~ /^[0-9]+([.][0-9]+)?$/ || value < 0 || value > 100) {
        print "ERROR: Missing or invalid metric: " value > "/dev/stderr"
        exit 1
    }
    print (value >= threshold)
}')"
if (( COMPARISON )); then
    echo "WARNING: High CPU Usage - $CPU%"
    ALERT_FOUND=true
fi

COMPARISON="$(LC_ALL=C awk -v value="$RAM" -v threshold="$RAM_THRESHOLD" '
BEGIN {
    if (value !~ /^[0-9]+([.][0-9]+)?$/ || value < 0 || value > 100) {
        print "ERROR: Missing or invalid metric: " value > "/dev/stderr"
        exit 1
    }
    print (value >= threshold)
}')"
if (( COMPARISON )); then
    echo "WARNING: High RAM Usage - $RAM%"
    ALERT_FOUND=true
fi

COMPARISON="$(LC_ALL=C awk -v value="$DISK" -v threshold="$DISK_THRESHOLD" '
BEGIN {
    if (value !~ /^[0-9]+([.][0-9]+)?$/ || value < 0 || value > 100) {
        print "ERROR: Missing or invalid metric: " value > "/dev/stderr"
        exit 1
    }
    print (value >= threshold)
}')"
if (( COMPARISON )); then
    echo "WARNING: High Disk Usage - $DISK%"
    ALERT_FOUND=true
fi

if [[ "$MONITOR_NETWORK" == Warning ]]; then
    echo "CRITICAL: Network Down"
    ALERT_FOUND=true
fi

if [[ "$MONITOR_SERVICE" == Warning ]]; then
    echo "CRITICAL: $SERVICE_NAME Stopped"
    ALERT_FOUND=true
fi

if [ "$ALERT_FOUND" = false ]; then
    echo "INFO: No Active Alerts"
fi

