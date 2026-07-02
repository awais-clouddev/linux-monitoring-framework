# Architecture Overview

## Purpose

The Enterprise Linux Monitoring & Automation Framework is designed to automate Linux system monitoring, collect health metrics, generate reports, and provide a web-based dashboard for administrators.

## Workflow

1. Administrator executes the monitoring framework.
2. Bash scripts collect CPU, RAM, Disk, Network, and Nginx metrics.
3. Results are stored in logs.
4. Health reports are generated.
5. Dashboard data is updated.
6. Nginx serves the dashboard.
7. Administrators monitor the system through a web browser.

## Components

- Ubuntu Linux
- Bash Scripts
- Cron Scheduler
- Nginx Web Server
- HTML Dashboard
- Health Reports
- Git Version Control

## Architecture Diagram

![Architecture Diagram](architecture.png)

The diagram above illustrates the complete workflow of the Enterprise Linux Monitoring & Automation Framework, including system monitoring, report generation, dashboard updates, and Nginx web delivery.

