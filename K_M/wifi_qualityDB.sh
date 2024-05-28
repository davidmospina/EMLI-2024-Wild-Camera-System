#!/bin/bash

# Create SQLite database file if it doesn't exist
DB_FILE="wifi_data.db"
if [ ! -e "$DB_FILE" ]; then
    sqlite3 "$DB_FILE" <<EOF
CREATE TABLE wifi_logs (
    id INTEGER PRIMARY KEY,
    epoch_time INTEGER,
    link_quality TEXT,
    signal_level TEXT
);
EOF
fi

while true; do
    # Get current time in seconds since epoch
    connected_network=$(nmcli device status | grep 'wifi' | awk '{print $3}'| head -n 1)
    epoch_time=$(date +%s)
    
    # Read link quality and signal level from /proc/net/wireless
    wireless_info=$(cat /proc/net/wireless | awk 'NR==3{print $3, $4}')
    read -r quality signal_level <<< "$wireless_info"
    
    if [[ -n $quality && -n $signal_level ]]; then
        # Insert data into SQLite database
        sqlite3 "$DB_FILE" "INSERT INTO wifi_logs (epoch_time, link_quality, signal_level) VALUES ($epoch_time, '$quality', '$signal_level');"
    else
        echo "Failed to read wireless info."
    fi
    
    if [ "$connected_network" != "connected" ]; then
        echo "disconnected to EMLI-TEAM-24."
        echo  "Exiting quality script ..."
        echo  "Relaunching wifi connection ..."
        ./connect_wifiDB2.sh
        exit
    fi
    
    sleep 1  # Wait for 1 second before reading again
done

