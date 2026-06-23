#!/bin/bash

SERVER_NAME="Pakistan-Server"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "===== ALERT CHECK ====="
echo "Server: $SERVER_NAME"
echo "Time: $TIMESTAMP"

CPU=$(top -bn1 | grep "Cpu(s)" | sed 's/,/ /g' | awk '{print 100 - $8}')
RAM=$(free | awk '/Mem:/ {printf("%.1f"), $3/$2 * 100}')
DISK=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

ALERT_FOUND=false

if (( $(echo "$CPU > 80" | bc -l) ))
then
echo "WARNING: High CPU Usage - $CPU%"
ALERT_FOUND=true
fi

if (( $(echo "$RAM > 80" | bc -l) ))
then
echo "WARNING: High RAM Usage - $RAM%"
ALERT_FOUND=true
fi

if [ "$DISK" -gt 80 ]
then
echo "WARNING: High Disk Usage - $DISK%"
ALERT_FOUND=true
fi

if ! ping -c 1 google.com > /dev/null
then
echo "CRITICAL: Network Down"
ALERT_FOUND=true
fi

if ! systemctl is-active --quiet nginx
then
echo "CRITICAL: Nginx Stopped"
ALERT_FOUND=true
fi

if [ "$ALERT_FOUND" = false ]
then
echo "INFO: No Active Alerts"
fi

