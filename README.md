# Ollama Installation and Web UI Setup Scripts

This package contains a set of scripts to automate the installation and management of Ollama and the Open WebUI on a Linux system.

## Overview

These scripts streamline the process of:
* Installs docker if needed
* Installing Ollama, including necessary GPU drivers (NVIDIA/AMD) and systemd service configuration.
  Ollama Install script is from https://ollama.com/install.sh. I modified service config in the script
* Running the Open WebUI using Docker.
* Stopping the Ollama service.
* Removing the Open WebUI Docker container and image.
* Automating the entire setup process with a single script.

## Scripts Included
1.  **`install-docker.sh`**
    * Checks which Linux Distro
    * Adds Docker repo
    * Installs Docker and Docker dependencies
    * Start and Enable Docker Services
    
3.  **`install-ollama.sh`**
    * Detects system architecture (amd64/arm64) and Linux distribution.
    * Downloads and installs the appropriate Ollama binary to `/usr/local/bin` (or similar standard bin directory).
    * Installs specific components for NVIDIA JetPack systems if detected.
    * Configures a systemd service (`ollama.service`) to run Ollama as a dedicated user (`ollama`) with specific environment variables (e.g., `OLLAMA_HOST`, `OLLAMA_CUDA`, cache size, vLLM settings).
    * Adds the current user to the `ollama` group.
    * Attempts to detect and install necessary NVIDIA CUDA drivers or AMD ROCm components if a compatible GPU is found and drivers are not already installed.
    * Sets up the Ollama service to start on boot.

4.  **`install-webui-docker.sh`**
    * Pulls the `ghcr.io/open-webui/open-webui:main` Docker image.
    * Runs a Docker container named `open-webui`.
    * Maps host port 3000 to container port 8080.
    * Mounts a Docker volume (`open-webui`) to `/app/backend/data` inside the container for persistent data.
    * Configures the container network to allow connection to the Ollama service running on the host (`host.docker.internal`).
    * Sets the container to restart automatically (`--restart always`).

5.  **`remove-webui-docker.sh`**
    * Finds the container ID for the running Open WebUI image (`ghcr.io/open-webui/open-webui:main`).
    * Stops and removes the found container.
    * Finds the image ID for the Open WebUI image.
    * Removes the Docker image *only if* no other containers (running or stopped) are using it.

6.  **`stop-ollama.sh`**
    * Checks if the `ollama.service` systemd service is active.
    * If active, it stops the service using `sudo systemctl stop ollama.service`.

7.  **`automate-ollama-install.sh`**
    * Executes the scripts in the following order:
        1.  `./install-docker.sh`  
        2.  `./stop-ollama.sh`
        3.  `./install-ollama.sh`
        4.  `./remove-webui-docker.sh`
        5.  `./install-webui-docker.sh`
    * This provides a complete teardown (of WebUI), installation/update (of Ollama), and setup sequence.

## Usage


To run the complete automated installation and setup process:

```bash
curl -sSL https://raw.githubusercontent.com/KompPsy/ollama-installation/refs/heads/main/automate-ollama-install.sh | sudo bash
