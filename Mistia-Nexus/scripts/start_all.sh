#!/bin/bash
# Starts all non-ignored services, ensuring the proxy starts first.

source "$(dirname "$0")/functions.sh"
cd "$(dirname "$0")/.."

print_status "header" "Starting All Services"

# --- Find and start the proxy first by checking for a docker-compose.yml file ---
PROXY_DIR=""
if [ -f "caddy/docker-compose.yml" ]; then
    PROXY_DIR="caddy"
elif [ -f "nginx-proxy/docker-compose.yml" ]; then
    PROXY_DIR="nginx-proxy"
fi

if [ -n "$PROXY_DIR" ]; then
    print_status "info" "Starting proxy service in '$PROXY_DIR' first..."
    (cd "$PROXY_DIR" && docker compose up -d) || { print_status "error" "Failed to start proxy service."; exit 1; }
    print_status "success" "Proxy service started."
else
    print_status "info" "No active proxy service (caddy or nginx-proxy with a docker-compose.yml) found. Skipping."
fi

# --- Start all other services ---
print_status "info" "Starting all other non-ignored services..."
for d in */ ; do
    if [ -d "$d" ] && [ -f "$d/docker-compose.yml" ]; then
        if [[ "$d" != "$PROXY_DIR/" && ! -f "$d/.ignore" ]]; then
            print_status "info" "Bringing up service in '$d'..."
            (cd "$d" && docker compose up -d --remove-orphans) || print_status "error" "Failed to start service in '$d'."
        fi
    fi
done

print_status "success" "All services have been started."
echo
print_status "info" "Current container status:"
docker ps