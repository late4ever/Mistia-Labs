#!/bin/bash
# Verifies the integrity of the actual Duplicati backup data.

source "$(dirname "$0")/functions.sh"
cd "$(dirname "$0")/.."

# --- START OF CONFIGURATION ---
BACKUP_JOB_NAME="Mistia-Nexus App to Data"
BACKUP_DEST_URL_CONTAINER="/nasroot/volume2/Backups/NAS-Apps"
SAMPLES_TO_TEST=3 # The number of remote backup versions to test.
# --- END OF CONFIGURATION ---

set -e # Exit immediately if a command exits with a non-zero status.

print_status "header" "Verifying Duplicati Backup Integrity"

print_status "info" "Step 1: Getting encryption passphrase..."
read -sp 'Please enter the Duplicati ENCRYPTION PASSPHRASE for this backup: ' DUP_PASSPHRASE
printf "\n"

print_status "info" "Step 2: Testing remote backup data for job '${BACKUP_JOB_NAME}'..."
# This command will download a sample of remote volumes and check their integrity.
(cd duplicati && docker compose exec -e PASSPHRASE="$DUP_PASSPHRASE" duplicati /app/duplicati/duplicati-cli test \
  "file://${BACKUP_DEST_URL_CONTAINER}" --backup-name="${BACKUP_JOB_NAME}" --samples="${SAMPLES_TO_TEST}")

print_status "success" "Backup integrity VERIFIED. No errors found in the tested samples."

exit 0