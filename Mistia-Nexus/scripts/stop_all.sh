#!/bin/bash
# Stops all non-ignored Docker services.

source "$(dirname "$0")/functions.sh"
cd "$(dirname "$0")/.."

print_status "header" "Stopping All Non-Ignored Docker Services"

for d in */ ; do
    if [ -d "$d" ] && [ -f "$d/docker-compose.yml" ]; then
        if [ ! -f "$d/.ignore" ]; then
            print_status "info" "Stopping service in '$d'..."
            (cd "$d" && docker compose down)
        else
            print_status "info" "Skipping ignored service in '$d'."
        fi
    fi
done

print_status "success" "All non-ignored services stopped."