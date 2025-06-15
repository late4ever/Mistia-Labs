#!/bin/bash
# Updates a single specified service, activating a profile if needed.

source "$(dirname "$0")/functions.sh"

if [ -z "$1" ]; then
  print_status "error" "No service name provided."
  echo "Usage: $0 <service_name> [profile_name_if_required]"
  exit 1
fi

SERVICE_NAME=$1
PROFILE_NAME=$2
cd "$(dirname "$0")/.."

print_status "header" "Updating Single Service: '$SERVICE_NAME'"

if [[ ! -d "$SERVICE_NAME" || ! -f "$SERVICE_NAME/docker-compose.yml" ]]; then
  print_status "error" "Service directory '$SERVICE_NAME' or its docker-compose.yml not found."
  exit 1
fi

# Build the docker compose command, adding the profile flag if provided.
COMPOSE_CMD="docker compose --env-file ../.env"
if [ ! -z "$PROFILE_NAME" ]; then
    print_status "info" "Using profile: '$PROFILE_NAME'"
    COMPOSE_CMD="$COMPOSE_CMD --profile $PROFILE_NAME"
fi

print_status "info" "Syncing with Git repository..."
git fetch origin > /dev/null 2>&1
git reset --hard origin/main > /dev/null 2>&1
chmod +x ./scripts/*.sh
print_status "success" "Repository synced."

print_status "info" "Pulling latest Docker image for '$SERVICE_NAME'..."
(cd "$SERVICE_NAME" && $COMPOSE_CMD pull) || { print_status "error" "Failed to pull Docker image for '$SERVICE_NAME'."; exit 1; }

print_status "info" "Recreating container for '$SERVICE_NAME'..."
(cd "$SERVICE_NAME" && $COMPOSE_CMD up -d --force-recreate --remove-orphans) || { print_status "error" "Failed to recreate container for '$SERVICE_NAME'."; exit 1; }

print_status "success" "Service '$SERVICE_NAME' has been updated and restarted."
echo
print_status "info" "Current status for '$SERVICE_NAME':"
(cd "$SERVICE_NAME" && docker compose ps)