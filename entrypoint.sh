#!/bin/bash

set -e

# Parse input arguments
HOST="$1"
USERNAME="$2"
PASSWORD="$3"
PORT="$4"
SCRIPT="$5"
ENVS="$6"

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

# Create a temporary script file with environment variables
TEMP_SCRIPT=$(mktemp)

# Process environment variables if provided
if [ -n "$ENVS" ]; then
    echo "Setting environment variables..."
    # Add environment variable exports to the script
    echo "# Environment variables" > "$TEMP_SCRIPT"
    
    # Split ENVS by comma and process each one
    IFS=',' read -ra ENV_ARRAY <<< "$ENVS"
    for env_var in "${ENV_ARRAY[@]}"; do
        # Trim whitespace
        env_var=$(echo "$env_var" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Skip empty values
        if [ -z "$env_var" ]; then
            continue
        fi
        
        # Validate format (should contain =)
        if [[ "$env_var" == *"="* ]]; then
            # Extract variable name and value
            var_name=$(echo "$env_var" | cut -d'=' -f1)
            var_value=$(echo "$env_var" | cut -d'=' -f2-)
            
            # Validate variable name (should start with letter or underscore, contain only alphanumeric and underscore)
            if [[ "$var_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                # Safely export the variable (escape special characters in value)
                printf 'export %s=%q\n' "$var_name" "$var_value" >> "$TEMP_SCRIPT"
                echo "  ✅ Set: $var_name"
            else
                echo "  ⚠️  Warning: Invalid variable name '$var_name', skipping"
            fi
        else
            echo "  ⚠️  Warning: Invalid format '$env_var', should be 'VAR=value', skipping"
        fi
    done
    
    echo "" >> "$TEMP_SCRIPT"
fi

# Add the main script
echo "$SCRIPT" >> "$TEMP_SCRIPT"

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