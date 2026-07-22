#!/bin/bash

set -Eeuo pipefail

DISK_THRESHOLD="${DISK_THRESHOLD:-80}"

if ! [[ "$DISK_THRESHOLD" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "ERROR: DISK_THRESHOLD must be numeric. Received: $DISK_THRESHOLD" >&2
    exit 1
fi

echo "===== DISK MONITOR ====="

DISK_USAGE="$(df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}')"

echo "Disk Usage: $DISK_USAGE%"

if (( $(echo "$DISK_USAGE < $DISK_THRESHOLD" | bc -l) )); then
    echo "Status: Healthy ✅"
else
    echo "Status: Warning ⚠️"
fi

