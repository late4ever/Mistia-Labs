#!/bin/bash
# Manual update git

source "$(dirname "$0")/functions.sh"

print_status "info" "Syncing with Git repository..."
git fetch origin > /dev/null 2>&1
git reset --hard origin/main > /dev/null 2>&1
chmod +x ./scripts/*.sh
print_status "success" "Repository synced."