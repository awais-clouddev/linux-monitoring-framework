# Troubleshooting Guide

## Common Issues

### Permission Denied

If the monitoring scripts cannot be executed, make them executable:

```bash
chmod +x scripts/*.sh
```

---

### Nginx Not Running

Check the Nginx service status:

```bash
sudo systemctl status nginx
```

Start the service if it is stopped:

```bash
sudo systemctl start nginx
```

---

### Dashboard Not Updating

Run the dashboard update script manually:

```bash
bash scripts/update_dashboard.sh
```

Then refresh the browser.

---

### Missing Runtime Commands

Numeric comparisons use awk; bc is no longer required.

```bash
sudo apt install -y gawk coreutils util-linux procps iputils-ping
```

---

### Cron Job Not Running

Verify that the Cron service is running:

```bash
sudo systemctl status cron
```

Review the current Cron configuration:

```bash
crontab -l
```

---

### Nginx Permission Denied

If Nginx cannot access the project dashboard through the symbolic link, allow traversal of the home directory:

```bash
chmod o+x /home/<username>
```

Replace `<username>` with your Linux username.

---

### Report or Log Files Not Generated

Run the complete monitoring workflow manually:

```bash
bash scripts/run_all_checks.sh
```

Then verify the generated files:

```bash
ls -l logs/
ls -l reports/
```


## WSL Service Startup

Without systemd, use sudo service nginx start and sudo service cron start.
WSL must remain active for scheduled jobs. Services may need restarting after WSL restarts.

## Stale Dashboard Data

Use readlink -f /var/www/html to confirm the link points to the current clone's dashboard directory. Compare http://localhost/status.txt with dashboard/status.txt. HTTP data checks do not verify browser layout.
