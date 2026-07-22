#!/bin/bash

set -Eeuo pipefail

CPU_THRESHOLD="${CPU_THRESHOLD:-80}"

if ! [[ "$CPU_THRESHOLD" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "ERROR: CPU_THRESHOLD must be numeric. Received: $CPU_THRESHOLD" >&2
    exit 1
fi

echo "===== CPU MONITOR ====="

CPU_USAGE="$(top -bn1 | grep "Cpu(s)" | sed 's/,/ /g' | awk '{printf "%.1f", 100 - $8}')"

echo "CPU Usage: $CPU_USAGE%"

if (( $(echo "$CPU_USAGE < $CPU_THRESHOLD" | bc -l) )); then
    echo "Status: Healthy ✅"
else
    echo "Status: Warning ⚠️"
fi

