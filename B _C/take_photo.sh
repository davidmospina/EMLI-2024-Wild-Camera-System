#!/bin/sh

DIR_BIN=`dirname $(readlink -f $0)`
cd $DIR_BIN

if [ -z "$1" ]; then
    echo "Usage: $0 <trigger_value>"
    exit 1
fi

trigger="$1"

# Get the current date and time
current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%H%M%S")
milliseconds=$(date +"%3N")

# Create the directory if it doesn't exist
directory="/home/raspberry/final_project/images/$current_date"
mkdir -p "$directory"

# Construct the filename
filename="${current_time}_${milliseconds}.jpg"

# Take a photo using the Raspberry Pi camera
rpicam-still -o "$directory/$filename" -t  0.01

# Define the log file path
LOG_FILE="/home/raspberry/final_project/log/log_events.txt"

# Get the current date
current_date=$(date '+%Y-%m-%d %H:%M:%S')

# Get the current epoch time
epoch_time=$(date '+%s')

# Define your custom string
custom_string="Photo taken."

# Write to the log file
echo "$current_date, $epoch_time, $custom_string" >> $LOG_FILE

# Print the location of the saved photo
echo "Photo saved as $directory/$filename"
./create_metadata.sh "$directory/$filename" "$trigger"

