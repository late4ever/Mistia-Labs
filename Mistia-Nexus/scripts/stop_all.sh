#!/bin/bash
# This script stops all Docker services defined in subdirectories.

# Navigate to the parent directory (Mistia-Nexus root)
# This is where the service folders (duplicati, portainer, etc.) live.
cd "$(dirname "$0")/.."

echo "Stopping all Docker services..."

for d in */ ; do
    if [ -f "$d/docker-compose.yml" ]; then
        echo "--- Stopping service in $d ---"
        (cd "$d" && docker compose down)
    fi
done

echo "All services stopped."