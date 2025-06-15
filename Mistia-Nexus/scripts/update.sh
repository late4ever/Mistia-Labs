#!/bin/bash
# Updates a single specified service.

source "$(dirname "$0")/functions.sh"

if [ -z "$1" ]; then
  print_status "error" "No service name provided."
  echo "Usage: $0 <service_name>"
  exit 1
fi

SERVICE_NAME=$1
cd "$(dirname "$0")/.."

print_status "header" "Updating Single Service: '$SERVICE_NAME'"

if [[ ! -d "$SERVICE_NAME" || ! -f "$SERVICE_NAME/docker-compose.yml" ]]; then
  print_status "error" "Service directory '$SERVICE_NAME' or its docker-compose.yml not found."
  exit 1
fi

print_status "info" "Syncing with Git repository..."
git fetch origin > /dev/null 2>&1
git reset --hard origin/main > /dev/null 2>&1
chmod +x ./scripts/*.sh
print_status "success" "Repository synced."

print_status "info" "Pulling latest Docker image for '$SERVICE_NAME'..."
(cd "$SERVICE_NAME" && docker compose pull)

print_status "info" "Recreating container for '$SERVICE_NAME'..."
# Using 'up --force-recreate' is the safest way to update without affecting shared networks.
(cd "$SERVICE_NAME" && docker compose up -d --force-recreate --remove-orphans)
print_status "success" "Service '$SERVICE_NAME' has been updated and restarted."
echo
print_status "info" "Current status for '$SERVICE_NAME':"
(cd "$SERVICE_NAME" && docker compose ps)