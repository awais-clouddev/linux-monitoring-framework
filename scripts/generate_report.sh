#!/bin/bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATUS_FILE="$PROJECT_DIR/dashboard/status.txt"
REPORT_DIR="$PROJECT_DIR/reports"
REPORT_FILE="$REPORT_DIR/daily_report.txt"
TEMP_FILE="$REPORT_DIR/.daily_report.tmp"

mkdir -p "$REPORT_DIR"

if [ ! -f "$STATUS_FILE" ]; then
    echo "ERROR: Dashboard status file not found: $STATUS_FILE" >&2
    exit 1
fi

{
    echo "===== DAILY SYSTEM REPORT ====="
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo ""
    echo "===== CURRENT STATUS ====="
    cat "$STATUS_FILE"
} > "$TEMP_FILE"

mv "$TEMP_FILE" "$REPORT_FILE"

echo "Report generated successfully: $REPORT_FILE"
