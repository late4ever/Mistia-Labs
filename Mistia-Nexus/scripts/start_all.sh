#!/bin/bash
# This script starts all Docker services defined in subdirectories.

# Navigate to the script's directory's parent (the Mistia-Nexus root)
cd "$(dirname "$0")/.."

echo "--- Starting shared network resources... ---"
# First, ensure the shared network is up and running.
docker compose up -d

echo "Starting all Docker services..."

for d in */ ; do
    # Ensure it's a directory and contains a docker-compose.yml file
    if [ -d "$d" ] && [ -f "$d/docker-compose.yml" ]; then
        echo "--- Starting service in $d ---"
        (cd "$d" && docker compose up -d --remove-orphans)
    fi
done

echo
echo "All services started."
echo "------------------------------------"
echo "Current container status:"
docker ps