#!/bin/bash

set -Eeuo pipefail

NETWORK_TARGET="${NETWORK_TARGET:-google.com}"

echo "===== NETWORK MONITOR ====="

if ping -c 1 -W 2 "$NETWORK_TARGET" > /dev/null 2>&1; then
    echo "Network Status: Healthy ✅"
else
    echo "Network Status: Warning ⚠️"
fi

