#!/bin/bash

# Ensure that the photo filename is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <photo_file_path>"
    exit 1
fi

# Ensure that the trigger value is provided
if [ -z "$2" ]; then
    echo "Usage: $0 <photo_file_path> <trigger_value>"
    exit 1
fi

# Extract the photo file path
photo_file="$1"
trigger="$2"
# Extract the photo filename and directory
photo_filename=$(basename "$photo_file")
photo_directory=$(dirname "$photo_file")

# Extract EXIF data using exiftool
exif_data=$(exiftool "$photo_file")

# Extract specific EXIF values
subject_distance=$(echo "$exif_data" | grep "Subject Distance" | awk -F': ' '{print $2}')
exposure_time=$(echo "$exif_data" | grep "Exposure Time" | awk -F': ' '{print $2}')
iso=$(echo "$exif_data" | grep "ISO" | awk -F': ' '{print $2}')

# Get current date and time in specific format
create_date=$(date +"%Y-%m-%d %H:%M:%S.$(date +"%3N")%:z")

# Get current seconds since epoch
create_seconds_epoch=$(date +"%s.%3N")

# Construct the JSON metadata content
json_content=$(cat <<EOF
{
    "File Name": "$photo_filename",
    "Create Date": "$create_date",
    "Create Seconds Epoch": $create_seconds_epoch,
    "Trigger": "$trigger",
    "Subject Distance": "${subject_distance:-0}",
    "Exposure Time": "$exposure_time",
    "ISO": "$iso"
}
EOF
)

# Define the JSON filename
json_filename="${photo_filename%.*}.json"

# Save the JSON content to the file
echo "$json_content" > "$photo_directory/$json_filename"

# Print the location of the saved JSON file
echo "Metadata saved as $photo_directory/$json_filename"

# Define the log file path
LOG_FILE="/home/raspberry/final_project/log/log_events.txt"

# Get the current date
current_date=$(date '+%Y-%m-%d %H:%M:%S')

# Get the current epoch time
epoch_time=$(date '+%s')

# Define your custom string
custom_string="Photo metadata created."

# Write to the log file
echo "$current_date, $epoch_time, $custom_string" >> $LOG_FILE
