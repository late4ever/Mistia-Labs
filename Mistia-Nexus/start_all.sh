#!/bin/bash
# This script starts all Docker services defined in subdirectories.

# Navigate to the script's directory
cd "$(dirname "$0")"

echo "Starting all Docker services..."

for d in */ ; do
    if [ -f "$d/docker-compose.yml" ]; then
        echo "--- Starting service in $d ---"
        (cd "$d" && docker-compose up -d)
    fi
done

echo "All services started."