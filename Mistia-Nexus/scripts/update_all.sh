#!/bin/bash
# Updates all non-ignored services.

source "$(dirname "$0")/functions.sh"

cd "$(dirname "$0")/.."

print_status "header" "Updating All Services"

print_status "info" "Step 1: Stopping all non-ignored services..."
./scripts/stop_all.sh || { print_status "error" "Failed to stop all services."; exit 1; }

print_status "info" "Step 2: Syncing with Git repository..."
git fetch origin > /dev/null 2>&1
git reset --hard origin/main > /dev/null 2>&1
chmod +x ./scripts/*.sh
print_status "success" "Repository synced."

print_status "info" "Step 3: Pulling/Building images for all non-ignored services..."
for d in */ ; do
    if [ -d "$d" ] && [ -f "$d/docker-compose.yml" ]; then
        if [ ! -f "$d/.ignore" ]; then        
            if grep -q "build:" "$d/docker-compose.yml"; then
                print_status "info" "Building Docker image for '$d' with --no-cache"
                (cd "$d" && docker compose build --no-cache) || { print_status "error" "Failed to build Docker image for '$d'."; exit 1; }
                print_status "success" "Image build completed for '$d'."
            else
                print_status "info" "Pulling latest Docker image for '$d'..."
                (cd "$d" && docker compose pull) || { print_status "error" "Failed to pull Docker image for '$d'."; exit 1; }
            fi
        fi
    fi
done
print_status "success" "Image pull/build attempt finished for all services."

print_status "info" "Step 4: Starting all services..."
./scripts/start_all.sh || { print_status "error" "Failed to start the stack."; exit 1; }

print_status "success" "Full stack update complete."