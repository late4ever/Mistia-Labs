#!/bin/bash
# Starts a single specified service.

source "$(dirname "$0")/functions.sh"

source "$(dirname "$0")/create-network.sh"

if [ -z "$1" ]; then
  print_status "error" "No service name provided."
  echo "Usage: $0 <service_name>"
  exit 1
fi

SERVICE_NAME=$1
cd "$(dirname "$0")/.."

print_status "header" "Starting Single Service: '$SERVICE_NAME'"

if [[ ! -d "$SERVICE_NAME" || ! -f "$SERVICE_NAME/docker-compose.yml" ]]; then
  print_status "error" "Service directory '$SERVICE_NAME' or its docker-compose.yml not found."
  exit 1
fi

print_status "info" "Bringing up container for '$SERVICE_NAME'..."
(cd "$SERVICE_NAME" && docker compose up -d) || { print_status "error" "Failed to bring up container for '$SERVICE_NAME'."; exit 1; }

print_status "success" "Service '$SERVICE_NAME' has been started."
echo
print_status "info" "Current status for '$SERVICE_NAME':"
(cd "$SERVICE_NAME" && docker compose ps --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}")
