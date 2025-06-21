#!/bin/bash
# Starts all non-ignored services, ensuring the proxy starts first.

source "$(dirname "$0")/functions.sh"
cd "$(dirname "$0")/.."

source "$(dirname "$0")/create-network.sh"

print_status "header" "Starting All Services"

# --- Find and start the proxy first ---
PROXY_DIR=$(get_active_proxy_dir)

if [ -n "$PROXY_DIR" ]; then
    print_status "info" "Starting proxy service in '$PROXY_DIR' first..."
    (cd "$PROXY_DIR" && docker compose up -d) || { print_status "error" "Failed to start proxy service."; exit 1; }
    print_status "success" "Proxy service started."
else
    print_status "info" "No active proxy service found. Skipping."
fi

# --- Start all other services ---
print_status "info" "Starting all other services..."
for d in */ ; do
    if [ -d "$d" ] && [ -f "$d/docker-compose.yml" ]; then
        if [[ "$d" != "$PROXY_DIR/" && ! -f "$d/.critical" && ! -f "$d/.ignore" ]]; then
            print_status "info" "Bringing up service in '$d'..."
            (cd "$d" && docker compose up -d --remove-orphans) || print_status "error" "Failed to start service in '$d'."
        fi
    fi
done

print_status "success" "All services have been started."
echo
print_status "info" "Current container status:"
docker ps --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"