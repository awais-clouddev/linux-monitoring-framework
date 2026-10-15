# Setup Guide

## Prerequisites

This project requires:

- Ubuntu 24.04+ or WSL Ubuntu
- Git
- Bash
- Nginx
- Cron
- `awk`, `coreutils`, and `util-linux` (`flock`)
- `procps`
- `iputils-ping`

Install the required packages:

```bash
sudo apt update
sudo apt install -y git nginx cron gawk coreutils util-linux procps iputils-ping
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
if [ "$(ps -p 1 -o comm=)" = systemd ]; then
    sudo systemctl enable --now nginx
else
    sudo service nginx start
fi
```

For a dedicated local lab, preserve the existing web directory and link the current dashboard:

```bash
# Dedicated local lab: preserve any existing web-root directory.
if [ -e /var/www/html ] && [ ! -L /var/www/html ]; then
    sudo mv -- /var/www/html "/var/www/html.backup.$(date +%Y%m%d%H%M%S)"
fi
sudo ln -sfnT "$(pwd)/dashboard" /var/www/html
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
if [ "$(ps -p 1 -o comm=)" = systemd ]; then
    sudo systemctl enable --now cron
else
    sudo service cron start
fi
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


## WSL Without systemd

If systemd is unavailable, start services using:

```bash
sudo service nginx start
sudo service cron start
```
