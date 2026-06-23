#!/bin/bash

echo "===== SERVICE MONITOR ====="

if systemctl is-active --quiet nginx
then
    echo "Nginx Status: Running ✅"
else
    echo "Nginx Status: Stopped ❌"
fi

