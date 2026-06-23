#!/bin/bash

CPU=$(top -bn1 | grep "Cpu(s)" | sed 's/,/ /g' | awk '{print 100 - $8}')

RAM=$(free | awk '/Mem:/ {printf("%.1f"), $3/$2 * 100}')

DISK=$(df -h / | awk 'NR==2 {print $5}')

if ping -c 1 google.com > /dev/null
then
NETWORK="Healthy"
else
NETWORK="Down"
fi

if systemctl is-active --quiet nginx
then
NGINX="Running"
else
NGINX="Stopped"
fi

echo "CPU: $CPU%" > dashboard/status.txt

echo "RAM: $RAM%" >> dashboard/status.txt

echo "Disk: $DISK" >> dashboard/status.txt

echo "Network: $NETWORK" >> dashboard/status.txt

echo "Nginx: $NGINX" >> dashboard/status.txt
echo "" >> dashboard/status.txt

echo "Alerts:" >> dashboard/status.txt

ALERTS=$(./scripts/alert_check.sh | tail -n +2)

if [ -z "$ALERTS" ]
then
echo "No Active Alerts" >> dashboard/status.txt
else
echo "$ALERTS" >> dashboard/status.txt
fi


