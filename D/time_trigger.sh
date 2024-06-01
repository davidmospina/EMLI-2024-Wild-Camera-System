#!/bin/bash

while true; do
    sleep 300 # Wait for 5 minutes

    # Define the log file path
    LOG_FILE="/home/raspberry/final_project/log/log_events.txt"

    # Get the current date
    current_date=$(date '+%Y-%m-%d %H:%M:%S')

    # Get the current epoch time
    epoch_time=$(date '+%s')

    # Define your custom string
    custom_string="5 minutes elapsed camera triggered."

    # Write to the log file
    echo "$current_date, $epoch_time, $custom_string" >> $LOG_FILE

    # Call the take_photo.sh script every 5 minutes
    /home/raspberry/final_project/scripts/take_photo.sh "Time"
done
