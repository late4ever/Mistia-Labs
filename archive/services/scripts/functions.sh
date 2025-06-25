#!/bin/bash
#
# This file contains shared bash functions for all management scripts.
#

# --- Colors for print_status ---
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[0;33m'
COLOR_NC='\033[0m' # No Color

# ---
# A standardized function for printing formatted status messages.
#
# @param $1 - The type of message (header|info|success|error)
# @param $2 - The message string to print
# ---
print_status() {
    TYPE=$1
    MESSAGE=$2

    case "$TYPE" in
        header)
            echo
            echo -e "${COLOR_BLUE}======================================================================${COLOR_NC}"
            echo -e "${COLOR_BLUE}=> $MESSAGE${COLOR_NC}"
            echo -e "${COLOR_BLUE}======================================================================${COLOR_NC}"
            ;;
        success)
            printf "${COLOR_GREEN}[SUCCESS]${COLOR_NC} %s\n" "$MESSAGE"
            ;;
        error)
            printf "${COLOR_RED}[ERROR]${COLOR_NC} %s\n" "$MESSAGE"
            ;;
        info)
            printf -- "${COLOR_YELLOW}-> %s${COLOR_NC}\n" "$MESSAGE"
            ;;
        *)
            echo "Unknown message type: $TYPE"
            ;;
    esac
}

# ---
# Determines the active proxy service by looking for a .active-proxy file.
#
# @return The directory name of the active proxy service, or an empty string if not found.
# ---
get_active_proxy_dir() {
    local proxy_file=".active-proxy"
    if [ -f "$proxy_file" ]; then
        local proxy_dir=$(cat "$proxy_file")
        if [ -d "$proxy_dir" ] && [ -f "$proxy_dir/docker-compose.yml" ]; then
            echo "$proxy_dir"
        else
            echo ""
        fi
    else
        echo ""
    fi
}