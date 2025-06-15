#!/bin/bash
# Updates all non-ignored services for a given profile.

source "$(dirname "$0")/functions.sh"

if [ -z "$1" ]; then
  print_status "error" "No profile name provided. Please specify 'caddy' or 'npm'."
  echo "Usage: $0 <profile_name>"
  exit 1
fi

PROFILE_NAME=$1
cd "$(dirname "$0")/.."

print_status "header" "Updating All Services for Profile: '$PROFILE_NAME'"

print_status "info" "Step 1: Stopping all non-ignored services..."
./scripts/stop_all.sh

print_status "info" "Step 2: Syncing with Git repository..."
git fetch origin > /dev/null 2>&1
git reset --hard origin/main > /dev/null 2>&1
chmod +x ./scripts/*.sh
print_status "success" "Repository synced."

print_status "info" "Step 3: Pulling images for all non-ignored services..."
for d in */ ; do
    if [ -d "$d" ] && [ -f "$d/docker-compose.yml" ]; then
        if [ ! -f "$d/.ignore" ]; then
            print_status "info" "Pulling image for service in '$d'..."
            (cd "$d" && docker compose pull)
        fi
    fi
done
print_status "success" "All images updated."

print_status "info" "Step 4: Starting all services with profile '$PROFILE_NAME'..."
./scripts/start_all.sh "$PROFILE_NAME"

print_status "success" "Full stack update complete."