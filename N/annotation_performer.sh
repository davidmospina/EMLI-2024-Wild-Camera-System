#!/bin/bash

# Parameters
image_file=$1
json_file=$2

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
        echo "Failed to update JSON content for $(basename "$image_file" .jpg)"
        exit 1
    fi

    echo "Updated JSON content: $updated_json"
    echo "$updated_json" > "$json_file"
else
    echo "JSON file $json_file does not exist."
    exit 1
fi

