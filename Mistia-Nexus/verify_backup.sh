#!/bin/bash
#
# Duplicati Automated Restore Test Script
# This script verifies the integrity of a Duplicati backup by creating a test file,
# backing it up, restoring it, and comparing the results.
#

# --- START OF CONFIGURATION ---

# The name of the Duplicati backup job you want to test, as seen in the web UI.
BACKUP_JOB_NAME="Mistia-Nexus App to Data"

# The full path on the NAS where the temporary test file will be created.
# This MUST be within the backup's source directory (e.g., /volume1/).
TEST_FILE_PATH="/volume1/duplicati_canary_file.txt"

# This is the path INSIDE the container's writable /config volume.
CONTAINER_RESTORE_PATH="/config/temp_restore_test"
# This is the corresponding path on the NAS HOST used for creating/verifying the folder.
HOST_RESTORE_PATH="/volume2/docker/Mistia-Nexus/duplicati/config/temp_restore_test"

# The unique content to write to the test file.
TEST_FILE_CONTENT="Backup and Restore successful on $(date)"

# --- END OF CONFIGURATION ---

set -e

# Function to print colored status messages
print_status() {
    COLOR_GREEN='\033[0;32m'
    COLOR_RED='\033[0;31m'
    COLOR_NC='\033[0m' # No Color
    if [ "$2" == "success" ]; then
        printf "${COLOR_GREEN}[SUCCESS]${COLOR_NC} %s\n" "$1"
    elif [ "$2" == "failure" ]; then
        printf "${COLOR_RED}[FAILURE]${COLOR_NC} %s\n" "$1"
    else
        printf "=> %s\n" "$1"
    fi
}

cleanup() {
    print_status "Running cleanup..."
    sudo rm -f "$TEST_FILE_PATH"
    sudo rm -rf "$HOST_RESTORE_PATH"
    print_status "Cleanup complete."
}

# Trap script exit to ensure cleanup runs even if errors occur
trap cleanup EXIT

# --- SCRIPT EXECUTION ---

# 1. Create the canary test file
print_status "Step 1: Creating test file at ${TEST_FILE_PATH}..."
echo "${TEST_FILE_CONTENT}" | sudo tee "$TEST_FILE_PATH" > /dev/null
print_status "Test file created." "success"

# 2. Find the Duplicati Backup Job ID
print_status "Step 2: Finding backup job ID for '${BACKUP_JOB_NAME}'..."
BACKUP_ID=$(docker exec duplicati duplicati-cli list-jobs | grep -B 1 "Name: ${BACKUP_JOB_NAME}" | head -n 1 | awk '{print $2}')

if [ -z "$BACKUP_ID" ]; then
    print_status "Could not find a backup job named '${BACKUP_JOB_NAME}'." "failure"
    exit 1
fi
print_status "Found Job ID: ${BACKUP_ID}" "success"

# 3. Run the Backup
print_status "Step 3: Starting backup job..."
docker exec duplicati duplicati-cli backup "${BACKUP_ID}" "$TEST_FILE_PATH"
print_status "Backup job completed." "success"

# 4. Restore the file
print_status "Step 4: Restoring test file to a writable location..."
# Securely prompt for the passphrase and pass it as an environment variable
read -sp 'Please enter the Duplicati ENCRYPTION PASSPHRASE for this backup: ' DUP_PASSPHRASE
printf "\n"

# Use the corrected host path to create the directory
sudo mkdir -p "$HOST_RESTORE_PATH"
sudo chown -R "$(id -u)":"$(id -g)" "$HOST_RESTORE_PATH" # Ensure we have permissions

# Use the corrected container path for the restore command
docker exec -e PASSPHRASE="$DUP_PASSPHRASE" duplicati duplicati-cli restore \
  "file://${CONTAINER_RESTORE_PATH}" \
  --backup-name="${BACKUP_JOB_NAME}" \
  --restore-path="$TEST_FILE_PATH" \
  --overwrite=true

print_status "Restore operation completed." "success"

# 5. Verify the restored file
print_status "Step 5: Verifying restored file..."
# Use the corrected host path to verify the file
RESTORED_FILE_PATH="${HOST_RESTORE_PATH}${TEST_FILE_PATH}" # Duplicati keeps the full path

if [ ! -f "$RESTORED_FILE_PATH" ]; then
    print_status "Restored file not found at '${RESTORED_FILE_PATH}'." "failure"
    exit 1
fi

RESTORED_CONTENT=$(cat "$RESTORED_FILE_PATH")

if [ "$TEST_FILE_CONTENT" == "$RESTORED_CONTENT" ]; then
    print_status "File content matches. Backup integrity VERIFIED." "success"
else
    print_status "File content MISMATCH. Backup may be corrupt." "failure"
    echo "Expected: ${TEST_FILE_CONTENT}"
    echo "Received: ${RESTORED_CONTENT}"
    exit 1
fi

# Cleanup is handled automatically by the 'trap' at the start
exit 0