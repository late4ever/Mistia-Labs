#!/bin/bash
#
# This script updates all services by orchestrating the stop, git sync,
# image pull, and start scripts/commands.
# It should be run from the 'scripts' directory.
#

# --- SCRIPT LOGIC ---

# Navigate to the parent directory (Mistia-Nexus root)
# This is where the service folders (duplicati, portainer, etc.) live.
cd "$(dirname "$0")/.."

echo "======================================================================"
echo "=> Step 1: Stopping all current Docker services..."
echo "======================================================================"
# Call the existing stop script
./scripts/stop_all.sh

echo
echo "======================================================================"
echo "=> Step 2: Forcibly syncing with the Git repository..."
echo "======================================================================"
# Fetch the latest state from the remote repository
git fetch origin

# Reset the local branch to match the remote, discarding any local changes
git reset --hard origin/main
echo "Local repository has been synchronized with GitHub."

echo
echo "======================================================================"
echo "=> Step 3: Pulling latest Docker images for all services..."
echo "======================================================================"

# Loop through each service directory to pull its specific image
for d in */ ; do
    # Ensure it's a directory and contains a docker-compose.yml file
    if [ -d "$d" ] && [ -f "$d/docker-compose.yml" ]; then
        echo "--- Pulling image for service in $d ---"
        (cd "$d" && docker compose pull)
    fi
done
echo "All images have been updated."

echo
echo "======================================================================"
echo "=> Step 4: Starting all Docker services with new configs/images..."
echo "======================================================================"
# Call the existing start script
./scripts/start_all.sh