#!/bin/bash
# Ensures the shared Docker network exists.

source "$(dirname "$0")/functions.sh"

NETWORK_NAME="mistia-proxy-net"

print_status "info" "Checking for '$NETWORK_NAME'..."
if ! docker network ls | grep -q "$NETWORK_NAME"; then
  print_status "info" "Network not found. Creating '$NETWORK_NAME'..."
  docker network create "$NETWORK_NAME"
  print_status "success" "Network '$NETWORK_NAME' created."
else
  print_status "success" "Network '$NETWORK_NAME' already exists."
fi