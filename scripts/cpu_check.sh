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

if (( $(echo "$CPU_USAGE < $CPU_THRESHOLD" | bc -l) )); then
    echo "Status: Healthy ✅"
else
    echo "Status: Warning ⚠️"
fi

