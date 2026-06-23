#!/bin/bash

echo "===== NETWORK MONITOR ====="

if ping -c 1 google.com > /dev/null
then
    echo "Network Status: Healthy ✅"
else
    echo "Network Status: Down ❌"
fi

