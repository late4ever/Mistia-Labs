#!/bin/bash
#
# This script adds a new service to the running stack without a full restart.
#

source "$(dirname "$0")/functions.sh"

if [ "$#" -ne 2 ]; then
  print_status "error" "Incorrect number of arguments."
  echo "Usage: $0 <new_service_directory> <active_proxy_profile>"
  echo "Example: $0 jellyfin caddy"
  exit 1
fi

NEW_SERVICE=$1
PROXY_PROFILE=$2
cd "$(dirname "$0")/.."

print_status "header" "Adding New Service: $NEW_SERVICE"

print_status "info" "Step 1: Syncing with Git repository..."
git fetch origin > /dev/null 2>&1
git reset --hard origin/main > /dev/null 2>&1
chmod +x ./scripts/*.sh
print_status "success" "Repository synced."

print_status "info" "Step 2: Verifying that service directories exist..."
if [ ! -d "$NEW_SERVICE" ]; then
  print_status "error" "Service directory '$NEW_SERVICE' not found even after syncing."
  exit 1
fi
if [ ! -d "$PROXY_PROFILE" ]; then
  print_status "error" "Proxy directory '$PROXY_PROFILE' not found."
  exit 1
fi
print_status "success" "Directories verified."

print_status "info" "Step 3: Updating reverse proxy '$PROXY_PROFILE'..."
./scripts/update.sh "$PROXY_PROFILE" || { print_status "error" "Failed to update the reverse proxy."; exit 1; }

print_status "info" "Step 4: Starting new service '$NEW_SERVICE'..."
(cd "$NEW_SERVICE" && docker compose pull) || { print_status "error" "Failed to pull image for '$NEW_SERVICE'."; exit 1; }
(cd "$NEW_SERVICE" && docker compose up -d) || { print_status "error" "Failed to start container for '$NEW_SERVICE'."; exit 1; }
print_status "success" "Service '$NEW_SERVICE' started."

echo
print_status "success" "🚀 New service deployment complete!"