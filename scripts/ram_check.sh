#!/bin/bash

echo "===== RAM MONITOR ====="

RAM_USAGE=$(free | awk '/Mem:/ {printf("%.1f"), $3/$2 * 100}')

echo "RAM Usage: $RAM_USAGE%"

