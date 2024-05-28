#!/bin/bash

# Define the CSV file and the folder containing images and metadata
CSV_FILE="images_registered.csv"
IMAGE_FOLDER="."

# Check if the CSV file exists
if [[ ! -f "$CSV_FILE" ]]; then
    echo "CSV file $CSV_FILE does not exist."
    exit 1
fi

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
            # Call ollama to get the description of the image
            # For debugging, let's just set description to a fixed value
            description=$(ollama run llava:7b "describe ./${image_file}")

            # Check if the JSON file exists
            if [[ -f "$json_file" ]]; then
                # Read the existing JSON file
                json_content=$(cat "$json_file")
                echo "Existing JSON content: $json_content"

                # Add the annotation to the JSON content
                updated_json=$(jq --arg description "$description" '.Annotation = {"Source": "Ollama:7b", "Text": $description}' <<< "$json_content")
                
                if [[ $? -ne 0 ]]; then
                    echo "Failed to update JSON content for $name"
                    continue
                fi

                echo "Updated JSON content: $updated_json"
                echo "$updated_json" > "$json_file"
            else
                echo "JSON file $json_file does not exist."
            fi
        else
            echo "Image file $image_file does not exist."
        fi
    fi
done < "$CSV_FILE"

