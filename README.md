# Ollama Installation and Web UI Setup Scripts
## Description
This package contains a set of scripts to automate the installation and management of Ollama and the Open WebUI on a Linux system.

## Prerequisites
Before running the installation scripts, ensure your system meets the following requirements:

1.  **Operating System:** A Linux distribution. The scripts have specific support for:
    * Debian-based systems (Debian, Ubuntu, etc.)
    * RHEL-based systems (CentOS, Fedora, Rocky Linux, Amazon Linux, etc.)
    * WSL2 (Windows Subsystem for Linux 2) is supported, but GPU passthrough requires specific configuration. WSL1 is *not* supported.
2.  **Architecture:** amd64 (x86_64) or arm64 (aarch64).
3.  **Internet Connection:** Required to download Ollama, Docker images, GPU drivers, and dependencies.
4.  **Permissions:** You will need `sudo` privileges or root access to run the installation scripts, as they install software, manage services, and modify user groups.
5.  **Required Tools:** The scripts depend on common command-line tools. The `install-ollama.sh` script specifically checks for:
    * `curl`
    * `awk`
    * `grep`
    * `sed`
    * `tee`
    * `xargs`
    The `install-docker.sh` script may install prerequisites like `ca-certificates`, `curl`, `gnupg`, and `yum-utils`/`dnf-plugins-core` depending on your distribution.
6.  **(Optional) GPU:**
    * **NVIDIA:** Compatible NVIDIA GPU with appropriate drivers. The `install-ollama.sh` script attempts to detect and install CUDA drivers if needed (requires `lspci` or `lshw` to be installed for detection).
    * **AMD:** Compatible AMD GPU. The `install-ollama.sh` script attempts to detect and install ROCm components if needed (requires `lspci` or `lshw` to be installed for detection).




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

### Installs / Updates OLLAMA and OpenWeb UI 
This is only to install / update OLLAMA and OpenWeb UI
```bash
curl -sSL https://raw.githubusercontent.com/KompPsy/ollama-installation/refs/heads/main/automate-ollama-install.sh | sudo bash
```
###  Installs / Updates OLLAMA
This is only to install / update OLLAMA
```bash
curl -sSL https://raw.githubusercontent.com/KompPsy/ollama-installation/refs/heads/main/install-ollama.sh | sudo bash
```
