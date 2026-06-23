#!/bin/bash

echo "===== DISK MONITOR ====="

DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')

echo "Disk Usage: $DISK_USAGE"

