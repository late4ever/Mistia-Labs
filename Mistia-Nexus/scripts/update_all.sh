#!/bin/bash
# Updates all non-ignored services for a given profile.

source "$(dirname "$0")/functions.sh"

if [ -z "$1" ]; then
  print_status "error" "No profile name provided."
  echo "Usage: $0 <profile_name> (e.g., 'caddy' or 'nginx-proxy')"
  exit 1
fi

PROFILE_NAME=$1
cd "$(dirname "$0")/.."

print_status "header" "Updating All Services for Profile: '$PROFILE_NAME'"

print_status "info" "Step 1: Stopping all non-ignored services..."
./scripts/stop_all.sh || { print_status "error" "Failed to stop all services."; exit 1; }

print_status "info" "Step 2: Syncing with Git repository..."
git fetch origin > /dev/null 2>&1
git reset --hard origin/main > /dev/null 2>&1
chmod +x ./scripts/*.sh
print_status "success" "Repository synced."

print_status "info" "Step 3: Pulling images for all non-ignored services..."
for d in */ ; do
    if [ -d "$d" ] && [ -f "$d/docker-compose.yml" ]; then
        if [ ! -f "$d/.ignore" ]; then
            print_status "info" "Pulling image for '$d'..."
            (cd "$d" && docker compose --env-file ../.env pull)
        fi
    fi
done
print_status "success" "Image pull attempt finished for all services."

print_status "info" "Step 4: Starting all services with profile '$PROFILE_NAME'..."
./scripts/start_all.sh "$PROFILE_NAME" || { print_status "error" "Failed to start the stack."; exit 1; }

print_status "success" "Full stack update complete."