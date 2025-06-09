#!/bin/bash
# This script pulls the latest images and restarts all Docker services.

# Navigate to the script's directory
cd "$(dirname "$0")"

echo "Updating all Docker services..."

for d in */ ; do
    if [ -f "$d/docker-compose.yml" ]; then
        echo "--- Updating service in $d ---"
        (cd "$d" && docker-compose pull && docker-compose up -d)
    fi
done

echo "All services updated."