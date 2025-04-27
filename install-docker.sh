#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
PACKAGES_TO_INSTALL="docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"

# --- Helper Functions ---
log_info() {
    echo "[INFO] $1"
}

log_warn() {
    echo "[WARN] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# --- Check for root/sudo privileges ---
if [ "$(id -u)" -ne 0 ]; then
  log_error "This script must be run as root or with sudo."
fi

# --- Check if Docker is already installed ---
if command -v docker &> /dev/null; then
    log_info "Docker command found. Assuming Docker is already installed. Skipping installation."
    docker --version # Optionally display the version
    exit 0
fi

log_info "Docker command not found. Proceeding with installation check..."

# --- Detect OS and Package Manager ---
OS_ID=""
PKG_MANAGER=""
UPDATE_CMD=""
INSTALL_CMD=""
PREREQ_PACKAGES=""

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
    VERSION_ID=$VERSION_ID # Needed for Debian/Ubuntu repo setup
    # Use ID_LIKE if available, otherwise fallback to ID
    OS_LIKE=${ID_LIKE:-$ID}
else
    log_error "Cannot determine the operating system. /etc/os-release not found."
fi

log_info "Detected OS: $OS_ID (like $OS_LIKE)"

# Check for Debian/Ubuntu derivatives
if [[ "$OS_LIKE" == *"debian"* || "$OS_LIKE" == *"ubuntu"* ]]; then
    PKG_MANAGER="apt-get"
    UPDATE_CMD="apt-get update"
    INSTALL_CMD="apt-get install -y"
    PREREQ_PACKAGES="ca-certificates curl gnupg"
    log_info "Using apt package manager."

    # --- Installation for Debian/Ubuntu ---
    log_info "Updating package list..."
    $UPDATE_CMD

    log_info "Installing prerequisite packages..."
    $INSTALL_CMD $PREREQ_PACKAGES

    log_info "Adding Docker's official GPG key..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/${OS_ID}/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    log_info "Setting up Docker repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${OS_ID} \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    log_info "Updating package list after adding repo..."
    $UPDATE_CMD

    log_info "Installing Docker packages: $PACKAGES_TO_INSTALL ..."
    $INSTALL_CMD $PACKAGES_TO_INSTALL

# Check for RHEL/CentOS/Fedora derivatives
elif [[ "$OS_LIKE" == *"rhel"* || "$OS_LIKE" == *"centos"* || "$OS_LIKE" == *"fedora"* ]]; then
    if command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        log_info "Using dnf package manager."
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        log_info "Using yum package manager."
    else
        log_error "Could not find dnf or yum package manager on RHEL-like system."
    fi

    INSTALL_CMD="$PKG_MANAGER install -y"
    PREREQ_PACKAGES="yum-utils" # dnf uses dnf-plugins-core, but yum-utils provides the command

    # --- Installation for RHEL-based ---
    log_info "Removing older Docker versions (if any)..."
    $PKG_MANAGER remove docker \
                      docker-client \
                      docker-client-latest \
                      docker-common \
                      docker-latest \
                      docker-latest-logrotate \
                      docker-logrotate \
                      docker-engine \
                      podman \
                      runc || true # Continue even if removal fails (packages might not exist)

    log_info "Installing prerequisite packages ($PREREQ_PACKAGES)..."
    $INSTALL_CMD $PREREQ_PACKAGES

    log_info "Setting up Docker repository..."
    # Use dnf config-manager if available, otherwise yum-config-manager
    if command -v dnf &> /dev/null; then
        dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    else
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    fi


    log_info "Installing Docker packages: $PACKAGES_TO_INSTALL ..."
    $INSTALL_CMD $PACKAGES_TO_INSTALL

    log_info "Starting and enabling Docker service..."
    systemctl start docker
    systemctl enable docker

else
    log_error "Unsupported operating system: $OS_ID. This script supports Debian, Ubuntu, and RHEL-based distributions."
fi

# --- Verification ---
log_info "Verifying Docker installation..."
if command -v docker &> /dev/null; then
    docker --version
    log_info "Docker installation completed successfully."
    # Optional: Run hello-world container
    # log_info "Running hello-world container to test..."
    # docker run hello-world
else
    log_error "Docker installation failed. The 'docker' command is not available after installation attempt."
fi

exit 0
