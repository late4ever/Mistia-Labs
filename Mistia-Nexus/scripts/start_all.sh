#!/bin/bash
# Starts all non-ignored services using a specified profile.

source "$(dirname "$0")/functions.sh"
cd "$(dirname "$0")/.."

if [ -z "$1" ]; then
  print_status "error" "No profile name provided. Please specify 'caddy' or 'npm'."
  echo "Usage: $0 <profile_name>"
  exit 1
fi

PROFILE_NAME=$1
print_status "header" "Starting All Services with Profile: '$PROFILE_NAME'"

COMPOSE_FILES=()
for d in */ ; do
    if [ -d "$d" ] && [ -f "$d/docker-compose.yml" ]; then
        if [ ! -f "$d/.ignore" ]; then
             COMPOSE_FILES+=("-f" "$d/docker-compose.yml")
        fi
    fi
done

if [ ${#COMPOSE_FILES[@]} -eq 0 ]; then
    print_status "error" "No non-ignored docker-compose.yml files found. Exiting."
    exit 1
fi

print_status "info" "Bringing up the stack..."
# This single command starts all services, including the correct profiled proxy.
docker compose "${COMPOSE_FILES[@]}" --profile "$PROFILE_NAME" up -d --remove-orphans

print_status "success" "All services for profile '$PROFILE_NAME' have been started."
echo
print_status "info" "Current container status:"
docker ps