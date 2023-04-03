#!/bin/bash

# Get the PIA username and password
PIA_USER=$PIA_USERNAME
PIA_PASS=$PIA_PASSWORD

# Get the Transmission port from the configuration file
TRANSMISSION_CONF="/usr/local/etc/transmission/home/settings.json"
TRANSMISSION_PORT=$(jq -r '.peer-port' "$TRANSMISSION_CONF")

# Check if port forwarding is enabled in PIA
PIA_STATUS=$(curl --silent "http://209.222.18.222:2000/?client_id=$PIA_USER&client_secret=$PIA_PASS&token=accept")
PIA_ENABLED=$(echo "$PIA_STATUS" | jq -r '.port_forwarding')

if [ "$PIA_ENABLED" != "true" ]; then
    echo "Error: Port forwarding is not enabled in PIA"
    exit 1
fi

# Get the open port from PIA
PIA_PORT=$(echo "$PIA_STATUS" | jq -r '.port')

# Change the Transmission port to the open port
jq ".\"peer-port\" = $PIA_PORT" "$TRANSMISSION_CONF" > "$TRANSMISSION_CONF.tmp" && mv "$TRANSMISSION_CONF.tmp" "$TRANSMISSION_CONF"

# Restart Transmission to apply the changes
service transmission restart

echo "Port forwarding has been set to port $PIA_PORT"