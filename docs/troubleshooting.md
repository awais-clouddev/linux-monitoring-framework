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

### Missing `bc` Package

If you receive a `bc: command not found` error, install the required package:

```bash
sudo apt install -y bc
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

