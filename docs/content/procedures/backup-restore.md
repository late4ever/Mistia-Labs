---
icon: simple/duplicati
---

# :simple-duplicati:{ .duplicati } Backup & Restore

!!! abstract "Overview"
    This document provides comprehensive procedures for backing up and restoring the Mistia-Nexus homelab infrastructure, including configuration files, application data, and complete system recovery.

## 💾 Backup Strategy

### 🛠️ Mistia Nexus App Backup

Create a daily, encrypted backup of the entire 2TB NVMe SSD (`volume1`) onto the 8TB HDD RAID 1 array (`volume2`). This protects against a failure of the high-performance NVMe drive.

These are the settings configured within the Duplicati web interface for this specific job.

<!-- markdownlint-disable MD033 -->
| Setting | Configuration |
|---------|-------------- |
| **Source Data** | `/nasroot/volume1/` (The entire NVMe drive) |
| **Destination** | `/nasroot/volume2/Backups/NAS-Apps/` |
| **Schedule** | Daily at 03:00 AM |
| **Encryption** | AES-256, built-in. **A passphrase is required for restore.** |
| **Backup Retention**| Keep the last 30 backups |
| **Exclusions** | The following protected system folders are excluded to prevent backing up of unnecessary runtime files:<ul><li>`/nasroot/volume1/@docker/`</li><li>`/nasroot/volume1/#recycle/`</li><li>`/nasroot/volume1/lost+found/`</li><li>`/nasroot/volume1/@tmp/`</li><li>`/nasroot/volume1/@appstore/`</li></ul> |

??? example "Mistia-Nexus-App-Backup-duplicati-config.json"
    ```json
    --8<-- "backup-config/Mistia-Nexus-App-Backup-duplicati-config.json"
    ```

## ↩️ Data Restoration

### 📂 Restore File(s) or Folder(s)

1. **Access Duplicati:** Log into the Duplicati web UI at `https://duplicati.mistia.xyz`

2. **Start Restore:** Click `Restore` >> `Direct restore from backup files`

3. **Connect to Backup:**
    * **Storage Type:** `Local folder or drive`
    * **Type Path:** `Click on Manually Type Path`
    * **For Mistia Nexus App:** Copy and paste this

        ```text
        /nasroot/volume2/Backups/NAS-Apps/
        ```

    * Click **"Test connection"**.

4. **Encryption:** Enter the **backup job's specific encryption passphrase**

5. **Select Files:** Browse the file tree and place a checkmark next to the specific file(s) or folder(s) you wish to restore

6. **Set Restore Options:**
    * **Restore to:** Select **"Restore to a different location"**
    * **Path:** Enter a temporary, writable path, such as `/config/temp_restore/`

7. **Click "Restore"**.

8. **Verify:** Go to the restored location and check for the restored files

### 🚨 Full Disaster Recovery

In this scenario, you have physically replaced the dead NVMe drive and re-run your IaC `setup.sh` script. The Duplicati container is running, but the `volume1` data is gone

1. **Access Duplicati:** Log into the Duplicati web UI. Your backup job will still exist because its configuration is safely stored on `volume2`

2. **Start Restore:** Click the **"Restore"** button directly on the main page. This will use the existing job configuration

3. **Select Files:** Choose the date/version you want to restore from. By default, it will select all files from that version to restore the entire volume

4. **Set Restore Options:**
    * **Restore to:** Select **"Original location"**. Duplicati will automatically restore all files to their correct paths inside `/nasroot/volume1/`
    * **Overwrite:** Choose how to handle conflicts if any files exist. For a clean slate, "Overwrite" is appropriate
  
5. **Click "Restore"**. Duplicati will begin restoring the entire contents of your NVMe drive from the backup stored on your HDDs
