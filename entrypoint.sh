#!/bin/bash

set -e

# Parse input arguments
HOST="$1"
USERNAME="$2"
PASSWORD="$3"
PORT="$4"
SCRIPT="$5"

# Validate required inputs
if [ -z "$HOST" ]; then
    echo "Error: Host is required"
    exit 1
fi

if [ -z "$USERNAME" ]; then
    echo "Error: Username is required"
    exit 1
fi

if [ -z "$PASSWORD" ]; then
    echo "Error: Password is required"
    exit 1
fi

if [ -z "$SCRIPT" ]; then
    echo "Error: Script is required"
    exit 1
fi

# Set default port if not provided
if [ -z "$PORT" ]; then
    PORT="22"
fi

echo "Connecting to $USERNAME@$HOST:$PORT"

# Create SSH client configuration to handle host key checking
mkdir -p ~/.ssh
echo "Host *" > ~/.ssh/config
echo "    StrictHostKeyChecking no" >> ~/.ssh/config
echo "    UserKnownHostsFile /dev/null" >> ~/.ssh/config
echo "    LogLevel ERROR" >> ~/.ssh/config
chmod 600 ~/.ssh/config

# Create a temporary script file
TEMP_SCRIPT=$(mktemp)
echo "$SCRIPT" > "$TEMP_SCRIPT"

# Execute the script on the remote host using sshpass
echo "Executing script on remote host..."
sshpass -p "$PASSWORD" ssh -p "$PORT" -o ConnectTimeout=30 "$USERNAME@$HOST" 'bash -s' < "$TEMP_SCRIPT"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Script executed successfully on $HOST"
else
    echo "Script execution failed on $HOST"
    exit 1
fi

# Clean up
rm "$TEMP_SCRIPT" 