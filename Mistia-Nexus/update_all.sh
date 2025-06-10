#!/bin/bash
# Navigate to the script's directory
cd "$(dirname "$0")"

echo "======================================================================"
echo "=> Step 1: Pulling latest configuration from Git..."
echo "======================================================================"
git pull

echo
echo "======================================================================"
echo "=> Step 2: Updating and restarting Docker services..."
echo "======================================================================"

for d in */ ; do
    if [ -f "$d/docker-compose.yml" ]; then
        echo "--- Processing service in $d ---"
        (cd "$d" && docker-compose pull && docker-compose up -d --remove-orphans)
        echo "------------------------------------"
    fi
done

echo
echo "All services have been updated."