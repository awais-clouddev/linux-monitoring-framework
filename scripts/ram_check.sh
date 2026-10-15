#!/bin/bash

set -Eeuo pipefail

export LC_ALL=C

RAM_THRESHOLD="${RAM_THRESHOLD:-80}"

if ! [[ "$RAM_THRESHOLD" =~ ^[0-9]+([.][0-9]+)?$ ]] ||
   ! LC_ALL=C awk -v value="$RAM_THRESHOLD" 'BEGIN {exit !(value >= 0 && value <= 100)}'; then
    echo "ERROR: RAM_THRESHOLD must be numeric and within 0–100. Received: $RAM_THRESHOLD" >&2
    exit 1
fi

echo "===== RAM MONITOR ====="

RAM_USAGE="$(free | awk '
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
}')"

echo "RAM Usage: $RAM_USAGE%"

COMPARISON="$(LC_ALL=C awk -v value="$RAM_USAGE" -v threshold="$RAM_THRESHOLD" '
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

