#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run with superuser privileges. Run with sudo."
  exit 1
fi

battery_name=$(ls /sys/class/power_supply | grep -E 'BAT[0-9]+|BATT' | head -n 1)

if [ -z "$battery_name" ]; then
  echo "Could not find the ASUS laptop battery name in /sys/class/power_supply."
else
  echo "The ASUS laptop battery name is: $battery_name"
fi

if ls /sys/class/power_supply/$battery_name/charge_control_end_threshold 1>/dev/null 2>&1; then

    read -p "Enter the battery charge limit: " charge_limit

    if [[ ! "$charge_limit" =~ ^[0-9]+$ ]] || ((charge_limit < 1 || charge_limit > 100)); then
        echo "Invalid input. Enter a number between 1 and 100."
        exit 1
    fi

    sudo bash -c "cat > /etc/systemd/system/battery-charge-threshold.service <<EOF
[Unit]
Description=Set the battery charge threshold
After=multi-user.target
StartLimitBurst=0

[Service]
Type=oneshot
Restart=on-failure
ExecStart=/bin/bash -c \"echo $charge_limit > /sys/class/power_supply/$battery_name/charge_control_end_threshold\"

[Install]
WantedBy=multi-user.target
EOF"

    sudo systemctl daemon-reload
    sudo systemctl enable battery-charge-threshold.service

    sudo systemctl start battery-charge-threshold.service

    echo "Service configured and enabled!"
else
    echo "The charge_control_end_threshold file was not found. Your laptop does not support charge threshold configuration."
fi
