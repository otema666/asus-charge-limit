#!/bin/bash

# Check if the script is running as a superuser
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run with superuser privileges. Run with sudo."
  exit 1
fi

# Check if the battery-charge-threshold service file exists
if [ -f "/etc/systemd/system/battery-charge-threshold.service" ]; then
    # Remove the service file
    sudo rm /etc/systemd/system/battery-charge-threshold.service

    # Reload systemd
    sudo systemctl daemon-reload

    echo "Battery charge threshold configuration removed."
else
    echo "Battery charge threshold configuration file not found. No changes made."
fi
