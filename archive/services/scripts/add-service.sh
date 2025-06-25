#!/bin/bash
# Adds a new service to the running stack without a full restart.

source "$(dirname "$0")/functions.sh"

if [ "$#" -ne 1 ]; then
  print_status "error" "No service name provided."
  echo "Usage: $0 <service_name>"
  exit 1
fi

NEW_SERVICE=$1

cd "$(dirname "$0")/.."

print_status "header" "Adding New Service: $NEW_SERVICE"

print_status "info" "Step 1: Syncing with Git repository..."
git fetch origin > /dev/null 2>&1
git reset --hard origin/main > /dev/null 2>&1
chmod +x ./scripts/*.sh
print_status "success" "Repository synced."

print_status "info" "Step 2: Verifying that service directory exists..."
if [ ! -f "$NEW_SERVICE/docker-compose.yml" ]; then
  print_status "error" "Service directory '$NEW_SERVICE' or its docker-compose.yml not found even after syncing."
  exit 1
fi
print_status "success" "Directory verified."

# --- Find the active proxy ---
PROXY_DIR=$(get_active_proxy_dir)

if [ -n "$PROXY_DIR" ]; then
    # Assuming the proxy is Caddy and its container name is 'caddy'
    PROXY_CONTAINER_NAME="caddy" 
    print_status "info" "Step 3: Reloading reverse proxy '$PROXY_CONTAINER_NAME' with new configuration..."
    docker exec "$PROXY_CONTAINER_NAME" caddy reload --config /etc/caddy/Caddyfile || { print_status "error" "Failed to reload the reverse proxy."; exit 1; }
    print_status "success" "Proxy reloaded successfully."
else
    print_status "info" "No active proxy service found, skipping proxy reload."
fi

print_status "info" "Step 4: Starting new service '$NEW_SERVICE'..."
(cd "$NEW_SERVICE" && docker compose pull) || { print_status "error" "Failed to pull image for '$NEW_SERVICE'."; exit 1; }
(cd "$NEW_SERVICE" && docker compose up -d) || { print_status "error" "Failed to start container for '$NEW_SERVICE'."; exit 1; }
print_status "success" "Service '$NEW_SERVICE' started."

echo
print_status "success" "🚀 New service deployment complete!"
