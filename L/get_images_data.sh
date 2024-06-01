#!/bin/bash

# Define the Raspberry Pi and local paths
RPI_USER="raspberry"
RPI_IP="192.168.10.1"  # Update this to the correct IP address of your Raspberry Pi
current_date=$(date +%Y-%m-%d)
RPI_SOURCE_DIR="/home/raspberry/final_project/images/$current_date"
LOCAL_DEST_DIR="./"
CSV_FILE="images_registered.csv"

# Create CSV file if it doesn't exist
if [ ! -f "$CSV_FILE" ]; then
    echo "file_name,status" > "$CSV_FILE"
fi

# Function to check if a file has already been copied
file_already_copied() {
    grep -Fq "$1" "$CSV_FILE"
}

# Function to check if connected to the correct Wi-Fi
is_connected_to_correct_wifi() {
    connected_network=$(nmcli device status | grep 'wifi' | awk '{print $3}' | head -n 1)
    wifi_name=$(nmcli -t -f active,ssid dev wifi | egrep '^yes:' | cut -d\' -f2)
    
    if [ "$connected_network" = "connected" ]; then
        echo "Currently connected to Wi-Fi network: $wifi_name"
        [ "$wifi_name" = "yes:EMLI-TEAM-24" ]
    else
        echo "Not connected to any Wi-Fi network"
        return 1
    fi
}

# Loop through all files in the source directory on the Raspberry Pi
while true; do
    if is_connected_to_correct_wifi; then
        echo "Connected to the correct Wi-Fi network: EMLI-TEAM-24"
        # Get the list of files in the source directory
        files=$(ssh $RPI_USER@$RPI_IP "ls $RPI_SOURCE_DIR")

        for file in $files; do
            if is_connected_to_correct_wifi; then
                # Check if the file is a .jpg or .json
                if [[ "$file" == *.jpg || "$file" == *.json ]]; then
                    base_name=$(basename "$file")
                    extension="${base_name##*.}"
                    base_name="${base_name%.*}"

                    # Process .jpg files
                    if [[ "$extension" == "jpg" ]]; then
                        json_file="$RPI_SOURCE_DIR/$base_name.json"
                        
                        # Check if the corresponding .json file exists
                        if ssh $RPI_USER@$RPI_IP "[ -e $json_file ]"; then
                            # Check if the files have already been copied
                            if ! file_already_copied "$base_name"; then
                                # Copy .jpg and .json files to the destination directory
                                echo "Copying $base_name.jpg and $base_name.json to $LOCAL_DEST_DIR"
                                scp "$RPI_USER@$RPI_IP:$RPI_SOURCE_DIR/$base_name.jpg" "$LOCAL_DEST_DIR"
                                scp "$RPI_USER@$RPI_IP:$RPI_SOURCE_DIR/$base_name.json" "$LOCAL_DEST_DIR"

                                # Check if the scp commands were successful
                                if [ $? -eq 0 ]; then
                                    echo "Files copied successfully, modifying $json_file"
                                    # Modify the .json file by adding the new field
                                    epoch_time=$(date +%s.%N)
                                    ssh $RPI_USER@$RPI_IP "sudo jq '. + {\"Drone Copy\": {\"Drone ID\": \"WILDDRONE-001\", \"Seconds Epoch\": $epoch_time}}' $json_file | sudo tee ${json_file}.tmp > /dev/null && sudo mv ${json_file}.tmp $json_file"


                                    # Mark the file as copied in the CSV file
                                    echo "$base_name,False" >> "$CSV_FILE"
                                else
                                    echo "Failed to copy files for $base_name"
                                fi
                            else
                                echo "$base_name has already been copied"
                            fi
                        else
                            echo "JSON file for $base_name not found"
                        fi
                    fi
                else
                    echo "Skipping non .jpg/.json file: $file"
                fi
            else
                echo "Disconnected from the correct Wi-Fi network: EMLI-TEAM-24"
                break
            fi
        done
    else
        echo "Not connected to the correct Wi-Fi network: EMLI-TEAM-24"
    fi
    sleep 1 # Wait for 60 seconds before checking again
done
