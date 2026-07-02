# Troubleshooting Guide

## Common Issues

### Permission Denied

```bash
chmod +x scripts/*.sh
```

### Nginx Not Running

```bash
sudo systemctl start nginx
sudo systemctl status nginx
```

### Dashboard Not Updating

Run:

```bash
bash scripts/update_dashboard.sh
```

### Git Push Rejected

```bash
git pull origin main --allow-unrelated-histories
git push
```

### Windows .png.png Issue

Save screenshots without typing the `.png` extension. Windows automatically adds it.

