#!/bin/bash
#
# This script updates all services by first stopping them, resetting any
# local changes, pulling all updates from Git and Docker Hub, and then
# restarting them with the new configurations.
#

# Navigate to the script's directory
cd "$(dirname "$0")"

echo "======================================================================"
echo "=> Step 1: Stopping all current Docker services..."
echo "======================================================================"
for d in */ ; do
    if [ -f "$d/docker-compose.yml" ]; then
        echo "--- Stopping service in $d ---"
        (cd "$d" && docker-compose down --remove-orphans)
    fi
done

echo
echo "======================================================================"
echo "=> Step 2: Forcibly syncing with the Git repository..."
echo "======================================================================"
git fetch origin
git reset --hard origin/main
echo "Local repository has been synchronized with GitHub."

echo
echo "======================================================================"
echo "=> Step 3: Pulling latest Docker images and restarting services..."
echo "======================================================================"

for d in */ ; do
    if [ -f "$d/docker-compose.yml" ]; then
        echo "--- Processing service in $d ---"
        (cd "$d" && docker-compose pull)
        (cd "$d" && docker-compose up -d --remove-orphans)
        echo "------------------------------------"
    fi
done

echo
echo "All services have been updated and restarted."
