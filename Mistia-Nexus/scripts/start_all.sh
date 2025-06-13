#!/bin/bash
# This script starts all Docker services defined in subdirectories.

# Navigate to the parent directory (Mistia-Nexus root)
# This is where the service folders (duplicati, portainer, etc.) live.
cd "$(dirname "$0")/.."

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
