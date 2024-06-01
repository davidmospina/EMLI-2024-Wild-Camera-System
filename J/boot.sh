#!/bin/bash
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Define the log file path
LOG_FILE="/home/raspberry/final_project/log/log_events.txt"

# Get the current date
current_date=$(date '+%Y-%m-%d %H:%M:%S')

# Get the current epoch time
epoch_time=$(date '+%s')

# Define your custom string
custom_string="System initialized."

# Write to the log file
echo "$current_date, $epoch_time, $custom_string" >> $LOG_FILE

/home/raspberry/final_project/scripts/camera_trigger/time_trigger.sh &
/home/raspberry/final_project/scripts/camera_trigger/motion_trigger.sh &
/home/raspberry/final_project/scripts/camera_trigger/external_trigger.sh &
/home/raspberry/final_project/scripts/rain_mqtt/rain_mqtt_handler.sh &
