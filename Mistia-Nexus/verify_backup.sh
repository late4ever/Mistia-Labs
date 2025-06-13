#!/bin/bash
#
# Duplicati Automated Restore Test Script (v5 - With Repair Step)
# This script verifies the integrity of a Duplicati backup by repairing the
# database, creating a test file, backing it up, restoring it, and comparing.
#

# --- START OF CONFIGURATION ---

BACKUP_JOB_NAME="Mistia-Nexus App to Data"
BACKUP_DEST_URL_CONTAINER="/nasroot/volume2/Backups/NAS-Apps"
TEST_FILE_PATH_HOST="/volume1/duplicati_canary_file.txt"
TEST_FILE_PATH_CONTAINER="/nasroot/volume1/duplicati_canary_file.txt"
CONTAINER_RESTORE_PATH="/config/temp_restore_test"
HOST_RESTORE_PATH="/volume2/docker/Mistia-Nexus/duplicati/config/temp_restore_test"
TEST_FILE_CONTENT="Backup and Restore successful on $(date)"

# --- END OF CONFIGURATION ---

set -e

print_status() {
    COLOR_GREEN='\033[0;32m'
    COLOR_RED='\033[0;31m'
    COLOR_NC='\033[0m' 
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
    sudo rm -f "$TEST_FILE_PATH_HOST"
    sudo rm -rf "$HOST_RESTORE_PATH"
    print_status "Cleanup complete."
}

trap cleanup EXIT

# --- SCRIPT EXECUTION ---

# 1. Create the canary test file
print_status "Step 1: Creating test file at ${TEST_FILE_PATH_HOST}..."
echo "${TEST_FILE_CONTENT}" | sudo tee "$TEST_FILE_PATH_HOST" > /dev/null
print_status "Test file created." "success"

# 2. Securely prompt for the passphrase once at the start
print_status "Step 2: Preparing to run test..."
read -sp 'Please enter the Duplicati ENCRYPTION PASSPHRASE for this backup: ' DUP_PASSPHRASE
printf "\n"

# 3. Repair the backup database to ensure consistency
print_status "Step 3: Repairing the local database (if necessary)..."
docker exec -e PASSPHRASE="$DUP_PASSPHRASE" duplicati /app/duplicati/duplicati-cli repair \
  "file://${BACKUP_DEST_URL_CONTAINER}" \
  --backup-name="${BACKUP_JOB_NAME}"
print_status "Repair operation completed." "success"

# 4. Run the Backup
print_status "Step 4: Starting backup job..."
docker exec -e PASSPHRASE="$DUP_PASSPHRASE" duplicati /app/duplicati/duplicati-cli backup \
  "file://${BACKUP_DEST_URL_CONTAINER}" \
  "${TEST_FILE_PATH_CONTAINER}" \
  --backup-name="${BACKUP_JOB_NAME}"

print_status "Backup job completed." "success"

# 5. Restore the file
print_status "Step 5: Restoring test file to a writable location..."
sudo mkdir -p "$HOST_RESTORE_PATH"
sudo chown -R "$(id -u)":"$(id -g)" "$HOST_RESTORE_PATH" 

docker exec -e PASSPHRASE="$DUP_PASSPHRASE" duplicati /app/duplicati/duplicati-cli restore \
  "file://${BACKUP_DEST_URL_CONTAINER}" \
  "${TEST_FILE_PATH_CONTAINER}" \
  --restore-path="${CONTAINER_RESTORE_PATH}" \
  --no-local-path=true \
  --overwrite=true

print_status "Restore operation completed." "success"

# 6. Verify the restored file
print_status "Step 6: Verifying restored file..."
TEST_FILENAME=$(basename "$TEST_FILE_PATH_HOST")
RESTORED_FILE_PATH="${HOST_RESTORE_PATH}/${TEST_FILENAME}" 

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

exit 0
