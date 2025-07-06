FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache \
    openssh-client \
    sshpass \
    bash

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"] 