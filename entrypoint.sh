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
ENV_EXPORTS=""
if [ -n "$ENVS" ]; then
    echo "Processing environment variables..."
    echo "Raw ENVS input: '$ENVS'"
    
    # Replace newlines with commas and handle both comma and newline delimited input
    CLEANED_ENVS=$(echo "$ENVS" | tr '\n' ',' | sed 's/,,*/,/g' | sed 's/^,//;s/,$//')
    echo "Cleaned ENVS: '$CLEANED_ENVS'"
    
    # Split by comma and process each one
    IFS=',' read -ra ENV_ARRAY <<< "$CLEANED_ENVS"
    echo "Number of environment variables to process: ${#ENV_ARRAY[@]}"
    for env_var in "${ENV_ARRAY[@]}"; do
        echo "Processing env_var: '$env_var'"
        # Trim whitespace
        env_var=$(echo "$env_var" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        echo "After trimming: '$env_var'"
        
        # Skip empty values
        if [ -z "$env_var" ]; then
            echo "  Skipping empty value"
            continue
        fi
        
        # Validate format (should contain =)
        if [[ "$env_var" == *"="* ]]; then
            # Extract variable name and value
            var_name=$(echo "$env_var" | cut -d'=' -f1)
            var_value=$(echo "$env_var" | cut -d'=' -f2-)
            
            # Validate variable name (should start with letter or underscore, contain only alphanumeric and underscore)
            if [[ "$var_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                # Build environment variable exports for SSH command (one per line)
                if [ -n "$ENV_EXPORTS" ]; then
                    ENV_EXPORTS="${ENV_EXPORTS}\n"
                fi
                ENV_EXPORTS="${ENV_EXPORTS}export ${var_name}=$(printf '%q' "$var_value")"
                echo "  ✅ Will set: $var_name"
            else
                echo "  ⚠️  Warning: Invalid variable name '$var_name', skipping"
            fi
        else
            echo "  ⚠️  Warning: Invalid format '$env_var', should be 'VAR=value', skipping"
        fi
    done
fi

# Build the complete script with environment variables
if [ -n "$ENV_EXPORTS" ]; then
    echo "Setting environment variables in remote session..."
    # Add environment variable exports at the beginning of the script
    echo "# Environment variables" > "$TEMP_SCRIPT"
    printf "%b\n" "$ENV_EXPORTS" >> "$TEMP_SCRIPT"
    echo "" >> "$TEMP_SCRIPT"
    # Add the main script
    echo "$SCRIPT" >> "$TEMP_SCRIPT"
else
    # No environment variables, just add the main script
    echo "$SCRIPT" > "$TEMP_SCRIPT"
fi

# Debug: Show the generated script (first 20 lines)
echo "Generated script preview:"
echo "========================="
head -n 20 "$TEMP_SCRIPT" | sed 's/^/  /'
echo "========================="
echo ""

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