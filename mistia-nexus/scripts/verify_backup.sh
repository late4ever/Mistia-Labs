#!/bin/bash
# Verifies the integrity of a Duplicati backup by running an isolated test.

source "$(dirname "$0")/functions.sh"
cd "$(dirname "$0")/.."

# --- START OF CONFIGURATION ---
# Main backup job settings (used for context, but not directly touched)
BACKUP_JOB_NAME="Mistia-Nexus App to Data"

# Verification-specific settings
VERIFICATION_JOB_NAME="${BACKUP_JOB_NAME} - Verification Test"
VERIFICATION_DEST_CONTAINER="/nasroot/volume2/Backups/NAS-Apps-Verification"
VERIFICATION_DEST_HOST="/volume2/Backups/NAS-Apps-Verification" # Host path to the verification destination
TEST_FILE_PATH_HOST="/volume1/duplicati_canary_file.txt"
TEST_FILE_PATH_CONTAINER="/nasroot/volume1/duplicati_canary_file.txt"
CONTAINER_RESTORE_PATH="/config/temp_restore_test"
HOST_RESTORE_PATH="/volume2/docker/mistia-nexus/duplicati/config/temp_restore_test"
TEST_FILE_CONTENT="Backup and Restore successful on $(date)"
# --- END OF CONFIGURATION ---

set -e # Exit immediately if a command exits with a non-zero status.

cleanup() {
    print_status "info" "Running cleanup..."
    # Remove local test file and restore directory
    sudo rm -f "$TEST_FILE_PATH_HOST"
    sudo rm -rf "$HOST_RESTORE_PATH"
    # Remove the temporary backup data from the verification destination
    print_status "info" "Removing temporary verification backup data..."
    sudo rm -rf "$VERIFICATION_DEST_HOST"
    print_status "info" "Cleanup complete."
}
trap cleanup EXIT # This ensures cleanup runs even if the script fails.

print_status "header" "Verifying Duplicati Backup Integrity (Isolated Test)"

# Ensure the verification destination is clean before starting
if [ -d "$VERIFICATION_DEST_HOST" ]; then
    print_status "info" "Clearing previous verification backup data..."
    sudo rm -rf "$VERIFICATION_DEST_HOST"
fi
sudo mkdir -p "$VERIFICATION_DEST_HOST"
sudo chown -R "$(id -u)":"$(id -g)" "$VERIFICATION_DEST_HOST"


print_status "info" "Step 1: Creating test file..."
echo "${TEST_FILE_CONTENT}" | sudo tee "$TEST_FILE_PATH_HOST" > /dev/null
print_status "success" "Test file created."

print_status "info" "Step 2: Getting encryption passphrase..."
read -sp 'Please enter the Duplicati ENCRYPTION PASSPHRASE for this backup: ' DUP_PASSPHRASE
printf "\n"

print_status "info" "Step 3: Starting isolated backup job..."
(cd duplicati && docker compose exec -e PASSPHRASE="$DUP_PASSPHRASE" duplicati /app/duplicati/duplicati-cli backup \
  "file://${VERIFICATION_DEST_CONTAINER}" "${TEST_FILE_PATH_CONTAINER}" --backup-name="${VERIFICATION_JOB_NAME}")
print_status "success" "Isolated backup job completed."

print_status "info" "Step 4: Restoring test file from isolated backup..."
sudo mkdir -p "$HOST_RESTORE_PATH"
sudo chown -R "$(id -u)":"$(id -g)" "$HOST_RESTORE_PATH"
(cd duplicati && docker compose exec -e PASSPHRASE="$DUP_PASSPHRASE" duplicati /app/duplicati/duplicati-cli restore \
  "file://${VERIFICATION_DEST_CONTAINER}" "${TEST_FILE_PATH_CONTAINER}" --backup-name="${VERIFICATION_JOB_NAME}" --restore-path="${CONTAINER_RESTORE_PATH}" --overwrite=true)
print_status "success" "Restore operation completed."

print_status "info" "Step 5: Verifying restored file..."
TEST_FILENAME=$(basename "$TEST_FILE_PATH_HOST")
RESTORED_FILE_PATH="${HOST_RESTORE_PATH}/${TEST_FILENAME}"

if [ ! -f "$RESTORED_FILE_PATH" ]; then
    print_status "error" "Restored file not found at '${RESTORED_FILE_PATH}'."
    exit 1
fi

RESTORED_CONTENT=$(cat "$RESTORED_FILE_PATH")
if [ "$TEST_FILE_CONTENT" == "$RESTORED_CONTENT" ]; then
    print_status "success" "File content matches. Backup integrity VERIFIED."
else
    print_status "error" "File content MISMATCH. Backup may be corrupt."
    echo "Expected: ${TEST_FILE_CONTENT}"
    echo "Received: ${RESTORED_CONTENT}"
    exit 1
fi

exit 0