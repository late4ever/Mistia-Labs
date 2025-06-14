#!/bin/bash
#
# This script updates a single specified service by first stopping it,
# then syncing with Git, pulling the service's latest Docker image,
# and finally restarting it.
#

# Check if a service name was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <service_name>"
  echo "Error: No service name provided."
  exit 1
fi

SERVICE_NAME=$1

# Navigate to the script's directory's parent (the Mistia-Nexus root)
cd "$(dirname "$0")/.."

# Check if the service directory exists before trying to operate on it
if [ ! -d "$SERVICE_NAME" ]; then
  echo "Error: Service directory '$SERVICE_NAME' not found in $(pwd)."
  exit 1
fi

# Check if docker-compose.yml exists for the service
if [ ! -f "$SERVICE_NAME/docker-compose.yml" ]; then
  echo "Error: No docker-compose.yml found for service '$SERVICE_NAME' in $(pwd)/$SERVICE_NAME."
  exit 1
fi

echo "======================================================================"
echo "=> Step 1: Stopping service '$SERVICE_NAME'..."
echo "======================================================================"
(cd "$SERVICE_NAME" && docker compose down)
echo "Service '$SERVICE_NAME' stopped."

echo
echo "======================================================================"
echo "=> Step 2: Forcibly syncing with the Git repository..."
echo "======================================================================"
# Fetch the latest state from the remote repository
git fetch origin

# Reset the local branch to match the remote, discarding any local changes
git reset --hard origin/main
echo "Local repository has been synchronized with GitHub."
chmod +x ./scripts/*.sh
echo "Management scripts are now executable."

echo
echo "======================================================================"
echo "=> Step 3: Pulling latest Docker image for '$SERVICE_NAME'..."
echo "======================================================================"
# Re-check for docker-compose.yml in case git sync removed/altered it critically,
# though 'docker compose pull' might handle this gracefully or error out.
# This check is optional but can provide a clearer error message.
if [ ! -f "$SERVICE_NAME/docker-compose.yml" ]; then
  echo "Error: docker-compose.yml for service '$SERVICE_NAME' is missing after git sync."
  echo "Cannot proceed with image pull and service start."
  exit 1
fi
(cd "$SERVICE_NAME" && docker compose pull)
echo "Image for '$SERVICE_NAME' updated."

echo
echo "======================================================================"
echo "=> Step 4: Starting service '$SERVICE_NAME'..."
echo "======================================================================"
(cd "$SERVICE_NAME" && docker compose up -d --remove-orphans)

echo
echo "Service '$SERVICE_NAME' has been updated and restarted."
echo "------------------------------------"
echo "Current status for '$SERVICE_NAME':"
(cd "$SERVICE_NAME" && docker compose ps)