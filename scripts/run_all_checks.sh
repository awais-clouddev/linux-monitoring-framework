#!/bin/bash

echo "===== Health Check: $(date '+%Y-%m-%d %H:%M:%S') ====="

./scripts/cpu_check.sh
./scripts/ram_check.sh
./scripts/disk_check.sh
./scripts/network_check.sh
./scripts/service_check.sh

echo ""

