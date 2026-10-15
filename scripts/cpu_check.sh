#!/bin/bash

set -Eeuo pipefail

export LC_ALL=C

CPU_THRESHOLD="${CPU_THRESHOLD:-80}"

if ! [[ "$CPU_THRESHOLD" =~ ^[0-9]+([.][0-9]+)?$ ]] ||
   ! LC_ALL=C awk -v value="$CPU_THRESHOLD" 'BEGIN {exit !(value >= 0 && value <= 100)}'; then
    echo "ERROR: CPU_THRESHOLD must be numeric and within 0–100. Received: $CPU_THRESHOLD" >&2
    exit 1
fi

echo "===== CPU MONITOR ====="

CPU_USAGE="$(top -bn2 -d 0.2 | awk '
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
}')"

echo "CPU Usage: $CPU_USAGE%"

COMPARISON="$(LC_ALL=C awk -v value="$CPU_USAGE" -v threshold="$CPU_THRESHOLD" '
BEGIN {
    if (value !~ /^[0-9]+([.][0-9]+)?$/ || value < 0 || value > 100) {
        print "ERROR: Missing or invalid metric: " value > "/dev/stderr"
        exit 1
    }
    print (value < threshold)
}')"
if (( COMPARISON )); then
    echo "Status: Healthy ✅"
else
    echo "Status: Warning ⚠️"
fi

