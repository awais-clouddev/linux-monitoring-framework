#!/bin/bash

REPORT=reports/daily_report.txt

echo "===== DAILY SYSTEM REPORT =====" > $REPORT

echo "Generated: $(date)" >> $REPORT

echo "" >> $REPORT

echo "===== CURRENT STATUS =====" >> $REPORT

cat dashboard/status.txt >> $REPORT

