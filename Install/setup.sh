#!/bin/bash
#
# Mistia-Nexus Homelab Setup Script (v4 - Streamlined)
# This script automates the setup of Docker services on a Ugreen NAS.
#

# --- START OF CONFIGURATION ---
# Static GitHub details. These are now hardcoded for simplicity.
GIT_USER="late4ever"
GIT_REPO="Mistia-Labs"
GIT_BRANCH="main"
NAS_USER="late4ever"
# The absolute path on your NAS where services will be deployed
DEPLOY_DIR="/volume2/docker"
# --- END OF CONFIGURATION ---

# Exit immediately if a command exits with a non-zero status.
set -e

# --- SCRIPT FUNCTIONS ---

# Function to print a formatted header
print_header() {
  echo
  echo "======================================================================"
  echo "=> $1"
  echo "======================================================================"
}

# --- SCRIPT EXECUTION ---

print_header "Starting Mistia-Nexus Homelab Setup"

# 1. Install System Dependencies
print_header "Step 1: Installing Git, Docker, and Docker Compose..."
sudo apt-get update
sudo apt-get install -y git docker.io docker-compose

# 2. Configure Docker Permissions
print_header "Step 2: Adding user '$NAS_USER' to the Docker group..."
sudo usermod -aG docker "$NAS_USER"
echo "NOTE: You may need to log out and log back in for this change to take full effect."
echo "The script will continue using 'sudo' for Docker commands."

# 3. Create Deployment Directory
print_header "Step 3: Creating deployment directory at '$DEPLOY_DIR'..."
sudo mkdir -p "$DEPLOY_DIR"
sudo chown "$NAS_USER":"$NAS_USER" "$DEPLOY_DIR"
cd "$DEPLOY_DIR"

# 4. Clone Repository using Sparse Checkout
print_header "Step 4: Preparing to clone from GitHub repository..."
if [ -d ".git" ]; then
  echo "Repository already seems to be cloned. Skipping."
else
  # Check if PAT was passed as an argument to the script ($1). If not, prompt for it.
  if [ -n "$1" ]; then
    GIT_PAT_INPUT="$1"
    echo "Using PAT provided by bootstrap..."
  else
    read -sp 'Please paste your GitHub Personal Access Token (PAT): ' GIT_PAT_INPUT
    printf "\n"
  fi

  if [ -z "$GIT_PAT_INPUT" ]; then
    echo "Error: No PAT provided. Aborting."
    exit 1
  fi

  echo "Cloning 'Mistia-Nexus' folder..."
  git init
  git remote add -f origin "https://${GIT_PAT_INPUT}@github.com/${GIT_USER}/${GIT_REPO}.git"
  git config core.sparseCheckout true
  echo "Mistia-Nexus/*" > .git/info/sparse-checkout
  git pull origin "$GIT_BRANCH"
fi

# 5. Set up the final structure
print_header "Step 5: Organizing deployed files..."
sudo mv Mistia-Nexus/* .
sudo rm -rf Mistia-Nexus

# 6. Set Script Permissions
print_header "Step 6: Setting permissions for management scripts..."
sudo chmod +x start_all.sh stop_all.sh update_all.sh

# 7. Deploy Docker Containers
print_header "Step 7: Starting all Docker services..."
./start_all.sh

print_header "Setup Complete!"
echo
echo "Your services are now running."
echo "-------------------------------------"
echo "Portainer: https://mistia-nexus.local:9444"
echo "Duplicati: http://mistia-nexus.local:8200"
echo "-------------------------------------"
echo "Remember to perform the post-install steps in the README (e.g., setting up Duplicati jobs)."
echo