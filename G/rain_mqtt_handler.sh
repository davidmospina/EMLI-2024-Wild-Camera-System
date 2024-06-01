#!/bin/bash

# Configuration
SERIAL_PORT="/dev/ttyACM0"
BAUD_RATE=115200

WIFI_SSID="EMLI_TEAM_24"
WIFI_PASSWORD="embeddedlinux"
MQTT_SERVER="10.0.0.10"
MQTT_SERVERPORT=1883
MQTT_USERNAME="raspberry"
MQTT_KEY="padajo"
MQTT_TOPIC="/rain"

ANGLE_LOW=10
ANGLE_HIGH=170
INITIAL_WIPER_ANGLE=10

# Set to true to enable debug prints, false to disable
DEBUG=true

# Function to print debug messages
debug_print() {
    if [[ "$DEBUG" == true ]]; then
        echo "$1"
    fi
}

# Install dependencies if not already installed
if ! command -v mosquitto_pub &> /dev/null || ! command -v mosquitto_sub &> /dev/null || ! command -v jq &> /dev/null; then
    debug_print "Installing dependencies..."
    sudo apt update
    sudo apt install -y mosquitto-clients jq
fi

# Function to validate JSON
is_json() {
    echo "$1" | jq empty > /dev/null 2>&1
    return $?
}

# Function to send initial serial message
send_initial_serial() {
    initial_message=$(jq -n --arg wa "$INITIAL_WIPER_ANGLE" '{"wiper_angle": $wa}')
    echo "$initial_message" >$SERIAL_PORT
    debug_print "Sent initial serial message: $initial_message"
}

# Function to read from serial and publish to MQTT
serial_to_mqtt() {
    stty -F $SERIAL_PORT $BAUD_RATE raw -echo
    while true; do
        if read -t 0.1 -r line <$SERIAL_PORT; then
            debug_print "Received from serial: $line"
            if is_json "$line"; then
                mosquitto_pub -h $MQTT_SERVER -p $MQTT_SERVERPORT -u $MQTT_USERNAME -P $MQTT_KEY -t $MQTT_TOPIC -m "$line"
            else
                debug_print "Invalid JSON received from serial, not publishing to MQTT."
            fi
        fi
    done
}

# Function to process message and send to serial
process_and_send() {
    local message="$1"
    local wiper_angle=$(echo "$message" | jq -r '.wiper_angle')
    local rain_detect=$(echo "$message" | jq -r '.rain_detect')

    if [[ "$rain_detect" == "0" ]]; then
        serial_message=$(jq -n --arg wa "$wiper_angle" '{"wiper_angle": $wa}')
    elif [[ "$rain_detect" == "1" ]]; then
        ##########LOG EVENT##########
        # Define the log file path
        LOG_FILE="/home/raspberry/final_project/log/log_events.txt"

        # Get the current date
        current_date=$(date '+%Y-%m-%d %H:%M:%S')

        # Get the current epoch time
        epoch_time=$(date '+%s')

        # Define your custom string
        custom_string="Rain detected moving screen wiper."

        # Write to the log file
        echo "$current_date, $epoch_time, $custom_string" >> $LOG_FILE
        if [[ "$wiper_angle" == "$ANGLE_LOW" ]]; then
            serial_message=$(jq -n --arg wa "$ANGLE_HIGH" '{"wiper_angle": $wa}')
        elif [[ "$wiper_angle" == "$ANGLE_HIGH" ]]; then
            serial_message=$(jq -n --arg wa "$ANGLE_LOW" '{"wiper_angle": $wa}')
        else
            debug_print "Invalid wiper_angle received: $wiper_angle"
            return
        fi
    else
        debug_print "Invalid rain_detect value: $rain_detect"
        return
    fi

    debug_print "Sending to serial: $serial_message"
    echo "$serial_message" >$SERIAL_PORT
}

# Function to listen to MQTT and send to serial
mqtt_to_serial() {
    mosquitto_sub -h $MQTT_SERVER -p $MQTT_SERVERPORT -u $MQTT_USERNAME -P $MQTT_KEY -t $MQTT_TOPIC | while read -r message; do
        debug_print "Received from MQTT: $message"
        if is_json "$message"; then
            process_and_send "$message"

        else
            debug_print "Invalid JSON received from MQTT, not sending to serial."
        fi
    done
}

# Send the initial serial message
send_initial_serial

# Run both functions in parallel
serial_to_mqtt &
mqtt_to_serial &

# Wait for all background processes to finish
wait
