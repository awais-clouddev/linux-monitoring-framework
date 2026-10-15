#!/bin/bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
REPORT_DIR="$PROJECT_DIR/reports"
LOG_FILE="$LOG_DIR/system_health.log"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

# All scheduled/manual workflows must use this entry point.
command -v flock >/dev/null 2>&1 || {
    echo "ERROR: flock is required." >&2
    exit 1
}
exec 9>"$LOG_DIR/.monitoring.lock"
if ! flock -n 9; then
    echo "INFO: Monitoring already running; skipping overlapping execution."
    exit 0
fi

cd "$PROJECT_DIR"


# Rotate before opening the log, while holding the workflow lock.
LOG_MAX_BYTES="${LOG_MAX_BYTES:-5242880}"
LOG_KEEP="${LOG_KEEP:-5}"

if ! [[ "$LOG_MAX_BYTES" =~ ^[1-9][0-9]{0,9}$ ]] ||
   ! [[ "$LOG_KEEP" =~ ^[1-9][0-9]?$ ]]; then
    echo "ERROR: LOG_MAX_BYTES must be a positive integer (max 10 digits); LOG_KEEP must be 1–99." >&2
    exit 1
fi

if [[ -f "$LOG_FILE" ]] &&
   (( $(stat -c %s "$LOG_FILE") >= LOG_MAX_BYTES )); then
    rm -f -- "$LOG_FILE.$LOG_KEEP"
    for ((i=LOG_KEEP-1; i>=1; i--)); do
        if [[ -f "$LOG_FILE.$i" ]]; then
            mv -- "$LOG_FILE.$i" "$LOG_FILE.$((i+1))"
        fi
    done
    mv -- "$LOG_FILE" "$LOG_FILE.1"
fi

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

