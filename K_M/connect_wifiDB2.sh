#!/bin/bash

# Function to check if a network is available and connect if found
check_network() {
    echo "check_network called"
    # Get list of available networks and check if "EMLI-TEAM-24" is present
    available_networks=$(nmcli device wifi list)
    if echo "$available_networks" | grep -q "EMLI-TEAM-24"; then
        echo "EMLI-TEAM-24 found. Connecting..."
        # Connect to the network
        nmcli device wifi connect "EMLI-TEAM-24"
    else
        echo "EMLI-TEAM-24 not found. Waiting..."
    fi
}

sync_time() {
    # Get PC's current time
    pc_time=$(date -u +"%Y-%m-%d %H:%M:%S")
    echo $pc_time
    # Synchronize Raspberry Pi's time with PC's time
    ssh raspberry@192.168.10.1 "sudo date -u -s '$pc_time'"
    echo "Time synchronized with PC."
}

# Function to launch quality WiFi script
launch_quality_wifi_script() {
    # Launch quality WiFi script
    echo "Launching quality WiFi script..."
    ./wifi_qualityDB.sh
    echo "Quality WiFi script launched."
}

# Loop indefinitely
while true; do
    connected_network=$(nmcli device status | grep 'wifi' | awk '{print $3}' | head -n 1)
    echo $connected_network
    if [ "$connected_network" = "connected" ]; then
        ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d':' -f2)

        echo "this is the current wifi $ssid"
        if [ "$ssid" = "EMLI-TEAM-24" ]; then
            echo "Connected to EMLI-TEAM-24. Synchronizing Time"
            sync_time
            echo "time synchronized."
            ssh raspberry@192.168.10.1 "sudo date +%Y%m%d%H%M.%S"
            launch_quality_wifi_script
            echo "Exiting ..."
            exit
    	else
	    # Check for the network
	    echo "calling check_network"
	    check_network
	    # Sleep for 10 seconds before checking again
        fi
    else
        # Check for the network
        echo "calling check_network"
        check_network
        # Sleep for 10 seconds before checking again
    fi
    sleep 10 
done


