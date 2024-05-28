#!/bin/bash

# Get the current date and time
current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%H%M%S")
milliseconds=$(date +"%3N")

DIR_BIN=`dirname $(readlink -f $0)`
cd $DIR_BIN

# Create the directory if it doesn't exist
directory="/home/raspberry/final_project/images/$current_date"
mkdir -p "$directory"
mkdir -p "$directory/temp"

# Counter to keep track of the number of photos taken
photo_counter=0

# Function to take a photo and call motion detection
take_photo_and_detect_motion() {
    # Increment photo counter
    ((photo_counter++))
    
    if [ "$photo_counter" -eq 1 ]; then
        filename1="${current_time}_${milliseconds}.jpg"
        rpicam-still -t 0.01 -o "$directory/temp/$filename1"
    elif [ "$photo_counter" -eq 2 ]; then
        filename2="${current_time}_${milliseconds}.jpg"
        rpicam-still -t 2000 -o "$directory/temp/$filename2"
    fi

    # If two photos have been taken, call motion detection script
    if [ "$photo_counter" -eq 2 ]; then
        echo "Calling motion detection script..."
        # Call motion detection script with the last two photos as parameters
        motion_detected=$(python3 motion_detect.py "$directory/temp/$filename1" "$directory/temp/$filename2")

	echo "result: $motion_detected"
        # Check the result of motion detection
        
        if [ "$motion_detected" == "True" ]; then
            # Define the log file path
            LOG_FILE="/home/raspberry/final_project/log/log_events.txt"

            # Get the current date
            current_date=$(date '+%Y-%m-%d %H:%M:%S')

            # Get the current epoch time
            epoch_time=$(date '+%s')

            # Define your custom string
            custom_string="Motion detected."

            # Write to the log file
            echo "$current_date, $epoch_time, $custom_string" >> $LOG_FILE

            # If motion was detected, save the last photo and create metadata
            echo "Motion detected. Saving last photo and creating metadata..."

            # Save the last photo and create metadata
            mv -f "$directory/temp/$filename2" "$directory/$filename2"

            # Define the log file path
            LOG_FILE="/home/raspberry/final_project/log/log_events.txt"

            # Get the current date
            current_date=$(date '+%Y-%m-%d %H:%M:%S')

            # Get the current epoch time
            epoch_time=$(date '+%s')

            # Define your custom string
            custom_string="Last photo saved."

            # Write to the log file
            echo "$current_date, $epoch_time, $custom_string" >> $LOG_FILE
	    ../create_metadata.sh "$directory/$filename2" "Motion"
        fi

        rm -f "$directory/temp/$filename1" "$directory/temp/$filename2"
        
        # Reset photo counter
        photo_counter=0
    fi
}

# Loop indefinitely
while true; do
    # Get the current date and time
    current_date=$(date +"%Y-%m-%d")
    current_time=$(date +"%H%M%S")
    milliseconds=$(date +"%3N")
    # Take a photo and detect motion
    take_photo_and_detect_motion
    # Sleep for 3 seconds before taking the next photo
    sleep 3
done

