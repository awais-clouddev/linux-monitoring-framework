#!/bin/bash

echo "===== CPU MONITOR ====="

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed 's/,/ /g' | awk '{print 100 - $8}')

echo "CPU Usage: $CPU_USAGE%"

if (( $(echo "$CPU_USAGE < 80" | bc -l) ))
then
    echo "Status: Healthy ✅"
else
    echo "Status: Warning ⚠️"
fi

