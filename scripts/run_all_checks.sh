#!/bin/bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
REPORT_DIR="$PROJECT_DIR/reports"
LOG_FILE="$LOG_DIR/system_health.log"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

cd "$PROJECT_DIR"

exec > >(tee -a "$LOG_FILE") 2>&1

trap 'echo "ERROR: Monitoring workflow failed at line $LINENO."' ERR

echo "===== Health Check: $(date '+%Y-%m-%d %H:%M:%S') ====="

./scripts/cpu_check.sh
./scripts/ram_check.sh
./scripts/disk_check.sh
./scripts/network_check.sh
./scripts/service_check.sh

echo ""
echo "Updating dashboard..."
./scripts/update_dashboard.sh

echo "Generating report..."
./scripts/generate_report.sh

echo "Monitoring workflow completed successfully."
echo "Log saved to: $LOG_FILE"
echo ""

