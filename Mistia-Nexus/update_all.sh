#!/bin/bash
#
# This script updates all services by first stopping them, pulling all updates,
# and then restarting them with the new configurations and images.
#

# Navigate to the script's directory
cd "$(dirname "$0")"

echo "======================================================================"
echo "=> Step 1: Stopping all current Docker services..."
echo "======================================================================"
for d in */ ; do
    if [ -f "$d/docker-compose.yml" ]; then
        echo "--- Stopping service in $d ---"
        (cd "$d" && docker-compose down)
    fi
done

echo
echo "======================================================================"
echo "=> Step 2: Pulling latest configuration from Git..."
echo "======================================================================"
git pull

echo
echo "======================================================================"
echo "=> Step 3: Pulling latest Docker images and restarting services..."
echo "======================================================================"

for d in */ ; do
    if [ -f "$d/docker-compose.yml" ]; then
        echo "--- Processing service in $d ---"
        (cd "$d" && docker-compose pull && docker-compose up -d --remove-orphans)
        echo "------------------------------------"
    fi
done

echo
echo "All services have been updated and restarted."
