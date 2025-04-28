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

## Scripts Detail


Here's a brief overview of what each individual script does:

1.  **`install-docker.sh`**
    * Checks if the `docker` command exists. If so, it exits assuming Docker is installed.
    * Detects the Linux distribution (Debian/Ubuntu/RHEL-based).
    * Installs prerequisite packages (`ca-certificates`, `curl`, `gnupg`, `yum-utils`/`dnf-plugins-core`).
    * Adds Docker's official GPG key and package repository.
    * Installs Docker Engine (`docker-ce`, `docker-ce-cli`, `containerd.io`, etc.).
    * Starts and enables the Docker service (on RHEL-based systems; Debian/Ubuntu usually handle this automatically).
    * Verifies the installation by running `docker --version`.

2.  **`install-ollama.sh`**
    * Detects system architecture (amd64/arm64) and Linux distribution.
    * Downloads the appropriate Ollama binary and installs it.
    * Installs specific components for NVIDIA JetPack systems if detected.
    * Checks for existing NVIDIA/AMD GPUs using `lspci`/`lshw` (if available).
    * Attempts to install NVIDIA CUDA drivers or AMD ROCm components if a compatible GPU is found and drivers seem missing.
    * Creates an `ollama` system user and group if they don't exist.
    * Adds the current user to the `ollama` group.
    * Creates and configures a systemd service (`/etc/systemd/system/ollama.service`) with specific environment variables (e.g., `OLLAMA_HOST=0.0.0.0`, GPU settings, cache size).
    * Enables and starts the `ollama.service` using `systemctl`.
    * #### NOTE: install-ollama.sh is from https://ollama.com/install.sh which I modified the service service files EOF section to improve performance for my ollama workloads.

3.  **`install-webui-docker.sh`**
    * Defines variables for port mapping, container name, volume name, image name, and network settings.
    * Executes `docker run` with appropriate options for detached mode, port mapping, host network access, volume mounting, container naming, and automatic restart.
    * Specifies the `ghcr.io/open-webui/open-webui:main` image.
    * Prints potential URLs to access the Web UI.

4.  **`remove-webui-docker.sh`**
    * Finds the container ID of the running container based on the Open WebUI image.
    * If found, stops (`docker stop`) and removes (`docker rm`) the container.
    * Finds the image ID of the Open WebUI image.
    * If found and no other containers use the image, removes the image (`docker rmi`).

5.  **`stop-ollama.sh`**
    * Checks if the `ollama.service` is active using `systemctl is-active --quiet`.
    * If active, stops the service using `sudo systemctl stop ollama.service`.
    * Reports whether the service was stopped or was already inactive.

6.  **`automate-ollama-install.sh`**
    * A simple script that executes the other scripts sequentially using `curl | sudo bash`:
        1.  `install-docker.sh`
        2.  `stop-ollama.sh`
        3.  `install-ollama.sh`
        4.  `remove-webui-docker.sh`
        5.  `install-webui-docker.sh`
           
6.  **`uninstall-ollama-open-webui.sh`**
   * A simple script that executes to uninstall ollama and OpenWebUI`

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

## Accessing the Open WebUI

Once the `install-webui-docker.sh` script (or the `automate-ollama-install.sh` script) has completed successfully, the Open WebUI will be running in a Docker container.

The script attempts to detect your server's IP address(es) and will print the URLs where you can access the interface. Typically, these will be:

* `http://localhost:3000` (if accessing from the same machine)
* `http://127.0.0.1:3000` (if accessing from the same machine)
* `http://<YOUR_SERVER_IP>:3000` (if accessing from another machine on the same network)

Replace `<YOUR_SERVER_IP>` with the actual local IP address of the machine running Ollama and the Web UI.

Open your web browser and navigate to one of these URLs. You should see the Open WebUI interface, ready to interact with your locally running Ollama models.

## Using Ollama CLI

After running the `install-ollama.sh` script, the `ollama` command-line tool is installed. You can use it directly from your terminal.

Common commands:

* **List local models:** `ollama list`
* **Pull a model:** `ollama pull <model_name>` (e.g., `ollama pull llama3`)
* **Run a model:** `ollama run <model_name>` (e.g., `ollama run llama3`)
* **See help:** `ollama --help`

*Note: If you just ran the installation script, you might need to log out and log back in, or run `newgrp ollama`, to use `ollama` commands without `sudo`.*

## Uninstallation 
### Uninstall Usage of Ollama and Open WebUI:
This script uninstalls OLLAMA and Open WebUI
```bash
curl -sSL https://raw.githubusercontent.com/KompPsy/ollama-installation/refs/heads/main/uninstall-ollama-open-webui.sh | sudo bash
```

