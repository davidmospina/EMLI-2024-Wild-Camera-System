#!/bin/bash

mosquitto_sub -h localhost -p 1883 -u raspberry -P padajo -t raspberry/external_trigger | while read -r line; do
    if [[ $line == *"Pressure plate triggered"* ]]; then
	# Define the log file path
	LOG_FILE="/home/raspberry/final_project/log/log_events.txt"

	# Get the current date
	current_date=$(date '+%Y-%m-%d %H:%M:%S')

	# Get the current epoch time
	epoch_time=$(date '+%s')

	# Define your custom string
	custom_string="Pressure plate activated camera triggered."

	# Write to the log file
	echo "$current_date, $epoch_time, $custom_string" >> $LOG_FILE

        /home/raspberry/final_project/scripts/take_photo.sh "External"
    fi
done
