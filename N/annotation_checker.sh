#!/bin/bash

# Define the CSV file and the folder containing images and metadata
CSV_FILE="images_registered.csv"
IMAGE_FOLDER="."

# Check if the CSV file exists
if [[ ! -f "$CSV_FILE" ]]; then
    echo "CSV file $CSV_FILE does not exist."
    exit 1
fi

# Loop to repeatedly check the CSV file every 3 seconds
while true; do
    # Iterate over each line in the CSV file
    while IFS=, read -r name annotated; do
        # Skip the header
        if [[ "$name" == "Name" ]]; then
            continue
        fi

        echo "Processing: $name with annotated status: $annotated"

        # Check if the image is not annotated
        if [[ "$annotated" == "false" ]]; then
            echo "Image to be annotated: $name"

            # Define the image and JSON file paths
            image_file="${IMAGE_FOLDER}/${name}.jpg"
            json_file="${IMAGE_FOLDER}/${name}.json"

            # Check if the image file exists
            if [[ -f "$image_file" ]]; then
                # Call the secondary script in the background
                ./annotation_performer.sh "$image_file" "$json_file" && sed -i "/^${name},/ s/,false$/,true/" "$CSV_FILE" &
            else
                echo "Image file $image_file does not exist."
            fi
        fi
        echo "finish $name cycle"
    done < "$CSV_FILE"
    
    wait
    echo "Waiting for 3 seconds before the next check..."
    sleep 3
done

