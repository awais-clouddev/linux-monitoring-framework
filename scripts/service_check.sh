#!/bin/bash

set -Eeuo pipefail

SERVICE_NAME="${SERVICE_NAME:-nginx}"

echo "===== SERVICE MONITOR ====="

if { if [ "$(ps -p 1 -o comm=)" = "systemd" ]; then
    { if [ "$(ps -p 1 -o comm=)" = "systemd" ]; then
    systemctl is-active --quiet "$SERVICE_NAME"
else
    service "$SERVICE_NAME" status >/dev/null 2>&1
fi; }
else
    service "$SERVICE_NAME" status >/dev/null 2>&1
fi; }; then
    echo "$SERVICE_NAME Status: Running ✅"
else
    echo "$SERVICE_NAME Status: Warning ⚠️"
fi

