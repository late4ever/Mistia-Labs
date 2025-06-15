#!/bin/bash
# Stops all non-ignored Docker services, ensuring the proxy stops last.

source "$(dirname "$0")/functions.sh"
cd "$(dirname "$0")/.."

print_status "header" "Stopping All Non-Ignored Docker Services"

# --- Find the active proxy ---
PROXY_DIR=""
if [ -f "caddy/docker-compose.yml" ]; then
    PROXY_DIR="caddy"
elif [ -f "nginx-proxy/docker-compose.yml" ]; then
    PROXY_DIR="nginx-proxy"
fi

# --- Stop all other services first ---
print_status "info" "Stopping all non-proxy services..."
for d in */ ; do
    if [ -d "$d" ] && [ -f "$d/docker-compose.yml" ]; then
        if [[ "$d" != "$PROXY_DIR/" && ! -f "$d/.ignore" ]]; then
            print_status "info" "Stopping service in '$d'..."
            (cd "$d" && docker compose down)
        fi
    fi
done

# --- Now, stop the proxy service last ---
if [ -n "$PROXY_DIR" ]; then
    print_status "info" "Stopping proxy service in '$PROXY_DIR'..."
    (cd "$PROXY_DIR" && docker compose down) || { print_status "error" "Failed to stop proxy service."; exit 1; }
    print_status "success" "Proxy service stopped."
else
    print_status "info" "No active proxy service found to stop."
fi

print_status "success" "All non-ignored services have been stopped."