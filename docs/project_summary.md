# Enterprise Linux Monitoring & Automation Framework

## Project Overview

This project is a Linux-based monitoring and automation framework built using Ubuntu, Bash scripting, Cron, and Nginx. It automates system health checks, generates reports, records execution logs, and updates a lightweight web dashboard for monitoring server status.

## Key Features

- CPU monitoring
- RAM monitoring
- Disk monitoring
- Network connectivity monitoring
- Nginx service monitoring
- Configurable monitoring thresholds
- Automated monitoring with Cron
- Persistent execution logs
- HTML monitoring dashboard
- Alert detection with INFO, WARNING, and CRITICAL levels
- System health report generation

## Architecture

The monitoring workflow is executed manually or automatically through Cron by running `run_all_checks.sh`.

The workflow performs the following steps:

1. Execute CPU, RAM, Disk, Network, and Service health checks.
2. Validate system status and detect alerts.
3. Record execution logs.
4. Update the monitoring dashboard.
5. Generate the latest system health report.
6. Display the latest monitoring information through Nginx.

## Technology Stack

- Ubuntu Linux
- Bash
- Cron
- Nginx
- HTML
- Git
- GitHub

