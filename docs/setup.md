# Setup Guide

## Prerequisites

This project requires:

- Ubuntu 24.04+ or WSL Ubuntu
- Git
- Bash
- Nginx
- Cron
- `bc`
- `procps`
- `iputils-ping`

Install the required packages:

```bash
sudo apt update
sudo apt install -y git nginx cron bc procps iputils-ping
```

## Clone the Repository

```bash
git clone https://github.com/awais-clouddev/linux-monitoring-framework.git
cd linux-monitoring-framework
```

## Make Scripts Executable

```bash
chmod +x scripts/*.sh
```

## Run the Framework Manually

```bash
bash scripts/run_all_checks.sh
```

## Configure Nginx

Start and enable Nginx:

```bash
sudo systemctl enable --now nginx
```

Remove the default Nginx web directory and create a symbolic link to the project dashboard:

```bash
sudo rm -rf /var/www/html
sudo ln -s "$(pwd)/dashboard" /var/www/html
```

Open the dashboard:

```text
http://localhost
```

## Configure Cron Automation

Open the current user's Cron configuration:

```bash
crontab -e
```

Add this entry to run the complete monitoring workflow every five minutes:

```cron
*/5 * * * * /home/USER/linux-monitoring-framework/scripts/run_all_checks.sh
```

Replace `/home/USER/linux-monitoring-framework` with the absolute path of the cloned project.

Verify the Cron job:

```bash
crontab -l
```

Ensure Cron is running:

```bash
sudo systemctl enable --now cron
```

## Verify the Generated Files

Dashboard status:

```bash
cat dashboard/status.txt
```

Health report:

```bash
cat reports/daily_report.txt
```

Execution log:

```bash
tail -20 logs/system_health.log
```

