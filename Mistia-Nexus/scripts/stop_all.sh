#!/bin/bash
# This script stops all Docker services defined in subdirectories.

# Navigate to the script's directory's parent (the Mistia-Nexus root)
cd "$(dirname "$0")/.."

echo "Stopping all Docker services..."

for d in */ ; do
    if [ -f "$d/docker-compose.yml" ]; then
        echo "--- Stopping service in $d ---"
        (cd "$d" && docker compose down)
    fi
done

echo "All services stopped."