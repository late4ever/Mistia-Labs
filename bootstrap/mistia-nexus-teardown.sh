#!/bin/bash
#
# Mistia-Nexus Homelab Teardown Script
# WARNING: THIS IS A DESTRUCTIVE SCRIPT. It will remove Docker containers,
# configuration, and installed packages related to the homelab setup.
#

# --- START OF CONFIGURATION ---

NAS_USER="late4ever"
DEPLOY_DIR="/volume2/docker"

# --- END OF CONFIGURATION ---

# --- SCRIPT FUNCTIONS ---

# Function to print a formatted header
print_header() {
  echo
  echo "======================================================================"
  echo "=> $1"
  echo "======================================================================"
}

# --- SCRIPT EXECUTION ---

print_header "Starting Mistia-Nexus Homelab Teardown"
echo "WARNING: This script will permanently delete your Docker containers and configurations."
read -p "Are you sure you want to continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Teardown aborted."
    exit 1
fi

# Step 1: Stop and Remove All Docker Containers
print_header "Step 1: Stopping and removing all Docker containers..."
if [ -f "${DEPLOY_DIR}/stop-all.sh" ]; then
    echo "Found stop_all.sh script. Running it now..."
    cd "$DEPLOY_DIR"
    ./stop_all.sh
    cd ~ # Move out of the directory before deleting it
else
    echo "stop-all.sh not found. Docker containers may need to be stopped manually."
fi

# Step 2: Delete the Deployment Directory
print_header "Step 2: Deleting the deployment directory..."
if [ -d "$DEPLOY_DIR" ]; then
    sudo rm -rf "$DEPLOY_DIR"
    echo "Directory '$DEPLOY_DIR' has been deleted."
else
    echo "Directory '$DEPLOY_DIR' not found. Skipping."
fi

# Step 3: Uninstall Docker, Compose, and Git
print_header "Step 3: Uninstalling packages..."
sudo apt-get purge --autoremove -y docker.io docker-compose git
echo "Packages docker.io, docker-compose, and git have been uninstalled."

# Step 4: Revert System Changes
print_header "Step 4: Reverting system changes..."
echo "Removing user '$NAS_USER' from the 'docker' group..."
sudo gpasswd -d "$NAS_USER" docker || echo "User was not in docker group or group does not exist. Skipping."

# Step 5: Clean up downloaded scripts from home directory
print_header "Step 5: Cleaning up bootstrap scripts..."
if [ -f ~/setup.sh ]; then
    rm ~/setup.sh
    echo "Removed ~/setup.sh"
fi
if [ -f ~/teardown.sh ]; then
    rm ~/teardown.sh
    echo "Removed ~/teardown.sh"
fi

print_header "Teardown Complete!"
echo "The system has been cleaned of the homelab setup."
echo "You can now reboot the NAS for a completely fresh state if desired ('sudo reboot')."
