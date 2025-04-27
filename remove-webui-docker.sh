#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
# set -u # Uncomment this if you want stricter variable checking

# --- Configuration ---
IMAGE_NAME="ghcr.io/open-webui/open-webui:main"

echo "--- Looking for container and image for: ${IMAGE_NAME} ---"

# --- Find Container ID ---
# Use docker ps to find the ID of a running container based on the ancestor image.
# --filter ancestor filters containers based on the image they were created from.
# --format "{{.ID}}" outputs only the container ID.
# Use head -n 1 to get only the first matching container ID if multiple exist.
CONTAINER_ID=$(docker ps --filter ancestor="${IMAGE_NAME}" --format "{{.ID}}" | head -n 1)

if [ -n "$CONTAINER_ID" ]; then
    echo "Found running container ID: ${CONTAINER_ID}"
else
    echo "No running container found for image ${IMAGE_NAME}."
fi

# --- Find Image ID ---
# Use docker images to find the ID of the specified image.
# --filter reference filters images by repository name and tag.
# -q or --quiet outputs only the numeric IDs.
IMAGE_ID=$(docker images --filter reference="${IMAGE_NAME}" -q | head -n 1)

if [ -n "$IMAGE_ID" ]; then
    echo "Found image ID: ${IMAGE_ID}"
else
    echo "No image found with name ${IMAGE_NAME}."
fi

echo # Add a newline for better readability

# --- Delete Container ---
if [ -n "$CONTAINER_ID" ]; then
    echo "Attempting to stop and remove container ${CONTAINER_ID}..."
    # Stop the container first (optional, but often safer)
    docker stop "${CONTAINER_ID}"
    # Remove the container
    docker rm "${CONTAINER_ID}"
    echo "Container ${CONTAINER_ID} removed."
else
    echo "Skipping container removal (no container found)."
fi

# --- Delete Image ---
if [ -n "$IMAGE_ID" ]; then
    # Check if any containers *still* exist using this image ID (even stopped ones)
    # This prevents errors when trying to remove an image used by a stopped container
    # that wasn't the one we initially targeted (or if docker stop failed).
    EXISTING_CONTAINERS=$(docker ps -a --filter ancestor="${IMAGE_ID}" -q)

    if [ -z "$EXISTING_CONTAINERS" ]; then
        echo "Attempting to remove image ${IMAGE_ID} (${IMAGE_NAME})..."
        docker rmi "${IMAGE_ID}"
        echo "Image ${IMAGE_ID} removed."
    else
        echo "Skipping image removal: Image ${IMAGE_ID} is still used by the following container(s):"
        echo "${EXISTING_CONTAINERS}"
        echo "Please remove these containers manually before removing the image."
    fi
else
    echo "Skipping image removal (no image found)."
fi

echo "--- Script finished ---"
