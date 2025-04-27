#!/bin/sh

# Define the service name
SERVICE_NAME="ollama.service"

echo "Checking status of ${SERVICE_NAME}..."

# Check if the service is active using systemctl is-active
# --quiet flag suppresses output and sets exit code: 0 if active, non-zero otherwise
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "${SERVICE_NAME} is currently active."
    echo "Attempting to stop ${SERVICE_NAME}..."

    # Stop the service using sudo
    if sudo systemctl stop "$SERVICE_NAME"; then
        echo "${SERVICE_NAME} stopped successfully."
    else
        echo "ERROR: Failed to stop ${SERVICE_NAME}. Check permissions or system logs." >&2
        exit 1 # Exit with error status
    fi
else
    # Check if the service exists but is inactive/failed, or if it doesn't exist at all
    if systemctl status "$SERVICE_NAME" > /dev/null 2>&1; then
        echo "${SERVICE_NAME} exists but is not currently active. No action needed."
    else
        echo "${SERVICE_NAME} does not appear to be installed or loaded. No action needed."
    fi
fi

exit 0 # Exit successfully

