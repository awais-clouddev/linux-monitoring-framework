#!/bin/bash

set -Eeuo pipefail

RAM_THRESHOLD="${RAM_THRESHOLD:-80}"

if ! [[ "$RAM_THRESHOLD" =~ ^[0-9]+([.][0-9]+)?$ ]] ||
   ! LC_ALL=C awk -v value="$RAM_THRESHOLD" 'BEGIN {exit !(value >= 0 && value <= 100)}'; then
    echo "ERROR: RAM_THRESHOLD must be numeric and within 0–100. Received: $RAM_THRESHOLD" >&2
    exit 1
fi

echo "===== RAM MONITOR ====="

RAM_USAGE="$(free | awk '/Mem:/ {printf "%.1f", $3/$2 * 100}')"

echo "RAM Usage: $RAM_USAGE%"

if (( $(echo "$RAM_USAGE < $RAM_THRESHOLD" | bc -l) )); then
    echo "Status: Healthy ✅"
else
    echo "Status: Warning ⚠️"
fi

