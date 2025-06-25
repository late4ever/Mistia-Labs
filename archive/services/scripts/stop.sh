#!/bin/bash
# Stops a single specified service.

source "$(dirname "$0")/functions.sh"

if [ -z "$1" ]; then
  print_status "error" "No service name provided."
  echo "Usage: $0 <service_name>"
  exit 1
fi

SERVICE_NAME=$1
cd "$(dirname "$0")/.."

print_status "header" "Stopping Single Service: '$SERVICE_NAME'"

if [[ ! -d "$SERVICE_NAME" || ! -f "$SERVICE_NAME/docker-compose.yml" ]]; then
  print_status "error" "Service directory '$SERVICE_NAME' or its docker-compose.yml not found."
  exit 1
fi

print_status "info" "Bringing down container for '$SERVICE_NAME'..."
(cd "$SERVICE_NAME" && docker compose down) || { print_status "error" "Failed to bring down container for '$SERVICE_NAME'."; exit 1; }

print_status "success" "Service '$SERVICE_NAME' has been stopped."
