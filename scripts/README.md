# Monitoring Scripts

This directory contains the Bash scripts used by the Linux monitoring and automation framework.

## Available Scripts

| Script | Purpose |
|---|---|
| `cpu_check.sh` | Monitors CPU usage against a configurable threshold |
| `ram_check.sh` | Monitors RAM usage against a configurable threshold |
| `disk_check.sh` | Monitors disk usage against a configurable threshold |
| `network_check.sh` | Verifies connectivity to a configurable network target |
| `service_check.sh` | Verifies the status of a configurable Linux service |
| `alert_check.sh` | Detects CPU, RAM, disk, network, and service alerts |
| `update_dashboard.sh` | Writes the latest monitoring results to the dashboard status file |
| `generate_report.sh` | Generates the latest system health report |
| `run_all_checks.sh` | Executes the complete monitoring workflow and records execution logs |

## Complete Workflow

`run_all_checks.sh` performs the following sequence:

```text
CPU Check
    ↓
RAM Check
    ↓
Disk Check
    ↓
Network Check
    ↓
Service Check
    ↓
Dashboard Update
    ↓
Report Generation
    ↓
Persistent Execution Log

