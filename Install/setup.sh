#!/bin/bash
#
# Mistia-Nexus Homelab Setup Script (v8)
# This script prepares the system for Docker, but does not start the containers.
#

# --- START OF CONFIGURATION ---

GIT_USER="late4ever"
GIT_REPO="Mistia-Labs"
GIT_BRANCH="main"
NAS_USER="late4ever"
NAS_GROUP="admin" 
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

# Step 1: Install System Dependencies
print_header "Step 1: Installing Git, Docker, and Docker Compose..."
sudo apt-get update
sudo apt-get install -y git docker.io

# Step 2: Start and Enable Docker Service
print_header "Step 2: Starting and enabling Docker service..."
sudo systemctl start docker
sudo systemctl enable docker
echo "Docker service started and enabled for auto-start on boot."

# Step 3: Configure Docker Permissions for current user
print_header "Step 3: Adding user '$NAS_USER' to the Docker group..."
sudo usermod -aG docker "$NAS_USER"
echo "NOTE: This change requires a new login session to take effect."

# Step 4: Create Deployment Directory and Set Correct Ownership
print_header "Step 4: Creating deployment directory and setting ownership..."
sudo mkdir -p "$DEPLOY_DIR"
sudo chown "$NAS_USER":"$NAS_GROUP" "$DEPLOY_DIR"
cd "$DEPLOY_DIR"

# Step 5: Clone Repository and Set Upstream Tracking
print_header "Step 5: Preparing to clone from GitHub repository..."
if [ -d ".git" ]; then
  echo "Repository already seems to be cloned. Skipping."
else
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

  # Get the name of the current local branch (likely 'master' or 'main')
  LOCAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  # Set the upstream tracking link for convenience
  git branch --set-upstream-to=origin/"$GIT_BRANCH" "$LOCAL_BRANCH"
  echo "Upstream branch set for easy 'git pull' in the future."
fi

# Step 6: Set Script Permissions
print_header "Step 6: Setting permissions for management scripts..."
cd "$DEPLOY_DIR"/Mistia-Nexus
sudo chmod +x scripts/*.sh

print_header "System Preparation Complete!"
echo
echo "The necessary packages have been installed and your repository has been cloned."
echo "The final step is to apply your user's new Docker permissions."
echo
echo "----------------------------------------------------------------------"
echo "IMPORTANT: Please log out of this SSH session now."
echo "  - Type 'exit' and press Enter."
echo "Then, log back in and follow the final instructions in the README."
echo "----------------------------------------------------------------------"
echo
