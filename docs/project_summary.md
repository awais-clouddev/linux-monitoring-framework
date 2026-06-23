# Multi-Region Linux Monitoring & Automation Framework

This project is a Linux-based monitoring and automation framework built using Ubuntu, Bash scripting, Cron, Nginx, logs, alerts, reports, and a live dashboard.

## Features

- CPU monitoring
- RAM monitoring
- Disk monitoring
- Network connectivity monitoring
- Nginx service monitoring
- Automated checks using Cron
- Centralized system health logs
- Live Nginx dashboard
- Alert system with INFO, WARNING, and CRITICAL levels
- Daily health report generation

## Architecture

Cron runs the monitoring manager script every 5 minutes. The manager triggers all health-check scripts, stores results in logs, updates the dashboard status file, and displays the latest system state through Nginx.

## Tech Stack

- Ubuntu Linux
- Bash
- Cron
- Nginx
- HTML
- System logs
