# Backup Job Documentation

## Mistia-Nexus App to Data

This document details the configuration and restoration procedures for the primary internal backup job, which protects the applications and data on the NVMe SSD (`volume1`).

### 1. Job Overview

* **Name:** `Mistia-Nexus App to Data`
* **Purpose:** To create a daily, encrypted backup of the entire 2TB NVMe SSD (`volume1`) onto the resilient 8TB HDD RAID 1 array (`volume2`). This protects against a failure of the high-performance NVMe drive.
* **Technology:** Duplicati, running as a Docker container.

---

### 2. Configuration Details

These are the settings configured within the Duplicati web interface for this specific job.

| Setting             | Value / Configuration                                                                                                                                                             |
| :------------------ | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source Data** | `/nasroot/volume1/` (The entire NVMe drive)                                                                                                                                         |
| **Destination** | `/nasroot/volume2/Backups/NAS-Apps/`                                                                                                                                                |
| **Schedule** | Daily at 03:00 AM                                                                                                                                                                 |
| **Encryption** | AES-256, built-in. **A unique, strong passphrase is required for restore.** |
| **Backup Retention**| Keep the last 30 backups (approximately one month of history).                                                                                                                    |
| **Exclusions** | The following protected system folders are excluded to prevent warnings and backup unnecessary runtime files:<ul><li>`/nasroot/volume1/@docker/`</li><li>`/nasroot/volume1/#recycle/`</li><li>`/nasroot/volume1/lost+found/`</li><li>`/nasroot/volume1/@tmp/`</li><li>`/nasroot/volume1/@appstore/`</li></ul> |

---

## Restoration Guide

There are two primary scenarios for restoring data from this backup.

### Scenario A: Restoring a Single File or Folder (Test/Accidental Deletion)

This process is safe and does not overwrite any existing data. It is the same process used to test your backups.

1. **Access Duplicati:** Log into the Duplicati web UI at `https://duplicati.mistia.xyz`.
2. **Start Restore:** Click **"Restore"** > **"Direct restore from backup files"**.
3. **Connect to Backup:**
    * **Storage Type:** `Local folder or drive`
    * **Path:** `/nasroot/volume2/Backups/NAS-Apps/`
    * Click **"Test connection"**.
4. **Decrypt:** When prompted, enter the **backup job's specific encryption passphrase**.
5. **Select Files:** Browse the file tree and place a checkmark next to the specific file(s) or folder(s) you wish to restore.
6. **Set Restore Options:**
    * **Restore to:** Select **"Restore to a different location"**.
    * **Path:** Enter a temporary, writable path, such as `/config/temp_restore/`.
7. **Click "Restore"**.
8. **Verify:** Go to your NAS via SSH and verify the restored files are present at `/volume2/docker/Mistia-Nexus/duplicati/config/temp_restore/`.

### Scenario B: Full Disaster Recovery (NVMe Drive has Failed)

In this scenario, you have physically replaced the dead NVMe drive and re-run your IaC `setup.sh` script. The Duplicati container is running, but the `volume1` data is gone.

1. **Access Duplicati:** Log into the Duplicati web UI. Your backup job will still exist because its configuration is safely stored on `volume2`.
2. **Start Restore:** Click the **"Restore"** button directly on the main page. This will use the existing job configuration.
3. **Select Files:** Choose the date/version you want to restore from. By default, it will select all files from that version to restore the entire volume.
4. **Set Restore Options:**
    * **Restore to:** Select **"Original location"**. Duplicati will automatically restore all files to their correct paths inside `/nasroot/volume1/`.
    * **Overwrite:** Choose how to handle conflicts if any files exist. For a clean slate, "Overwrite" is appropriate.
5. **Click "Restore"**. Duplicati will begin restoring the entire contents of your NVMe drive from the backup stored on your HDDs.
