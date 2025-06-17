#!/bin/bash
#
# This file contains shared bash functions for all management scripts.
#

# --- Colors for print_status ---
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_BLUE='\033[0;34m'
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
            printf -- "-> %s\n" "$MESSAGE"
            ;;
        *)
            echo "Unknown message type: $TYPE"
            ;;
    esac
}