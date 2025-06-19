#!/bin/bash
# Verifies the integrity of a Duplicati backup.

source "$(dirname "$0")/functions.sh"
cd "$(dirname "$0")/.."

# --- START OF CONFIGURATION ---
BACKUP_JOB_NAME="Mistia-Nexus App to Data"
BACKUP_DEST_URL_CONTAINER="/nasroot/volume2/Backups/NAS-Apps"
TEST_FILE_PATH_HOST="/volume1/duplicati_canary_file.txt"
TEST_FILE_PATH_CONTAINER="/nasroot/volume1/duplicati_canary_file.txt"
CONTAINER_RESTORE_PATH="/config/temp_restore_test"
HOST_RESTORE_PATH="/volume2/docker/Mistia-Nexus/duplicati/config/temp_restore_test"
TEST_FILE_CONTENT="Backup and Restore successful on $(date)"
# --- END OF CONFIGURATION ---

set -e # Exit immediately if a command exits with a non-zero status.

cleanup() {
    print_status "info" "Running cleanup..."
    sudo rm -f "$TEST_FILE_PATH_HOST"
    sudo rm -rf "$HOST_RESTORE_PATH"
    print_status "info" "Cleanup complete."
}
trap cleanup EXIT # This ensures cleanup runs even if the script fails.

print_status "header" "Verifying Duplicati Backup Integrity"

print_status "info" "Step 1: Creating test file..."
echo "${TEST_FILE_CONTENT}" | sudo tee "$TEST_FILE_PATH_HOST" > /dev/null
print_status "success" "Test file created."

print_status "info" "Step 2: Getting encryption passphrase..."
read -sp 'Please enter the Duplicati ENCRYPTION PASSPHRASE for this backup: ' DUP_PASSPHRASE
printf "\n"

print_status "info" "Step 3: Repairing the local database (if necessary)..."
(cd duplicati && docker compose exec -e PASSPHRASE="$DUP_PASSPHRASE" duplicati /app/duplicati/duplicati-cli repair \
  "file://${BACKUP_DEST_URL_CONTAINER}" --backup-name="${BACKUP_JOB_NAME}")
print_status "success" "Repair operation completed."

print_status "info" "Step 4: Starting backup job..."
(cd duplicati && docker compose exec -e PASSPHRASE="$DUP_PASSPHRASE" duplicati /app/duplicati/duplicati-cli backup \
  "file://${BACKUP_DEST_URL_CONTAINER}" "${TEST_FILE_PATH_CONTAINER}" --backup-name="${BACKUP_JOB_NAME}")
print_status "success" "Backup job completed."

print_status "info" "Step 5: Restoring test file..."
sudo mkdir -p "$HOST_RESTORE_PATH"
sudo chown -R "$(id -u)":"$(id -g)" "$HOST_RESTORE_PATH"
(cd duplicati && docker compose exec -e PASSPHRASE="$DUP_PASSPHRASE" duplicati /app/duplicati/duplicati-cli restore \
  "file://${BACKUP_DEST_URL_CONTAINER}" "${TEST_FILE_PATH_CONTAINER}" --restore-path="${CONTAINER_RESTORE_PATH}" --overwrite=true)
print_status "success" "Restore operation completed."

print_status "info" "Step 6: Verifying restored file..."
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

print_status "info" "Step 7: Finalizing with a database repair..."
(cd duplicati && docker compose exec -e PASSPHRASE="$DUP_PASSPHRASE" duplicati /app/duplicati/duplicati-cli repair \
  "file://${BACKUP_DEST_URL_CONTAINER}" --backup-name="${BACKUP_JOB_NAME}")
print_status "success" "Final repair completed. Database is ready for next job."

exit 0