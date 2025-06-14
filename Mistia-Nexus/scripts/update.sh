#!/bin/bash
#
# This script updates a single specified service by first stopping it,
# pulling its latest Docker image, and then restarting it.
#

# Check if a service name was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <service_name>"
  echo "Error: No service name provided."
  exit 1
fi

SERVICE_NAME=$1

# Navigate to the script's directory's parent (the Mistia-Nexus root)
cd "$(dirname "$0")/.."

# Check if the service directory exists
if [ ! -d "$SERVICE_NAME" ]; then
  echo "Error: Service directory '$SERVICE_NAME' not found in $(pwd)."
  exit 1
fi

# Check if docker-compose.yml exists for the service
if [ ! -f "$SERVICE_NAME/docker-compose.yml" ]; then
  echo "Error: No docker-compose.yml found for service '$SERVICE_NAME' in $(pwd)/$SERVICE_NAME."
  exit 1
fi

echo "======================================================================"
echo "=> Step 1: Stopping service '$SERVICE_NAME'..."
echo "======================================================================"
(cd "$SERVICE_NAME" && docker compose down)
echo "Service '$SERVICE_NAME' stopped."

echo
echo "======================================================================"
echo "=> Step 2: Pulling latest Docker image for '$SERVICE_NAME'..."
echo "======================================================================"
(cd "$SERVICE_NAME" && docker compose pull)
echo "Image for '$SERVICE_NAME' updated."

echo
echo "======================================================================"
echo "=> Step 3: Starting service '$SERVICE_NAME'..."
echo "======================================================================"
(cd "$SERVICE_NAME" && docker compose up -d --remove-orphans)

echo
echo "Service '$SERVICE_NAME' has been updated and restarted."
echo "------------------------------------"
echo "Current status for '$SERVICE_NAME':"
(cd "$SERVICE_NAME" && docker compose ps)