# Setup Guide

## Clone Repository

```bash
git clone https://github.com/awais-clouddev/linux-monitoring-framework.git
cd linux-monitoring-framework
```

## Make Scripts Executable

```bash
chmod +x scripts/*.sh
```

## Run Monitoring Framework

```bash
bash scripts/run_all_checks.sh
```

## Generate Daily Report

```bash
bash scripts/generate_report.sh
```

## View Dashboard

Start a local web server:

```bash
cd dashboard
python3 -m http.server 8080
```

Open:

```
http://localhost:8080
```

