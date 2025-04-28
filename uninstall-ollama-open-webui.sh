#!/bin/bash

OLLAMAlibPATH=/usr/local/lib/ollama
OLLAMASHAREPATH=usr/share/ollama
USERGROUP=ollama
OLLAMASERVICE=/etc/systemd/system/ollama.service
VOLUME_NAME="open-webui"

echo "Searching for Docker volume named '${VOLUME_NAME}'..."


curl -sSL https://raw.githubusercontent.com/KompPsy/ollama-installation/main/remove-webui-docker.sh | sudo bash

FOUND_VOLUME=$(docker volume ls --filter name="^${VOLUME_NAME}$" -q)

# Check if the volume was found
if [ -z "$FOUND_VOLUME" ]; then
    echo "Volume '${VOLUME_NAME}' not found."
    exit 1 # Exit with an error code
fi

echo "Found volume: ${FOUND_VOLUME}"

# Check if any containers (running or stopped) are using this volume
echo "Checking if volume '${FOUND_VOLUME}' is used by any containers..."
CONTAINERS_USING_VOLUME=$(docker ps -a --filter volume="${FOUND_VOLUME}" -q)

# Check if the list of containers is non-empty
if [ -n "$CONTAINERS_USING_VOLUME" ]; then
    echo "Error: Volume '${FOUND_VOLUME}' is currently used by the following container(s):"
    # List the container IDs (or names if you prefer, remove -q)
    docker ps -a --filter volume="${FOUND_VOLUME}" --format "{{.ID}} {{.Names}}" # More informative output
    echo "Please stop and remove these containers before deleting the volume."
    echo "Skipping volume removal."
    exit 1 # Exit with an error code
else
    # No containers are using the volume, proceed with removal
    echo "Volume '${FOUND_VOLUME}' is not currently in use by any containers."
    echo "Attempting to remove volume '${FOUND_VOLUME}'..."
    
    # Attempt to remove the volume
    if docker volume rm "${FOUND_VOLUME}"; then
        echo "Volume '${FOUND_VOLUME}' removed successfully."
        exit 0 # Exit successfully
    else
        echo "Error: Failed to remove volume '${FOUND_VOLUME}'."
        # This might happen due to permissions or other Docker issues
        exit 1 # Exit with an error code
    fi
fi

rm -rf ${OLLAMAlibPATH}
rm -rf ${OLLAMASHAREPATH}
systemctl disable ${USERGROUP} --now
rm -rf ${OLLAMASERVICE}
rm -rf ~/.cache/*

