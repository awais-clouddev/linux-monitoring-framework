#!/bin/bash

set -Eeuo pipefail

SERVICE_NAME="${SERVICE_NAME:-nginx}"

echo "===== SERVICE MONITOR ====="

if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "$SERVICE_NAME Status: Running ✅"
else
    echo "$SERVICE_NAME Status: Warning ⚠️"
fi

