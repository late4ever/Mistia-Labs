---
icon: simple/duplicati
---

# :simple-duplicati:{ .duplicati } Backup & Restore

<!-- markdownlint-disable MD033 -->

!!! abstract "Overview"
    This document provides comprehensive procedures for backing up and restoring the Mistia-Nexus homelab infrastructure, including configuration files, application data, and complete system recovery.

## 💾 Backup Strategy

### 🛠️ Mistia Nexus App Backup

Create a daily, encrypted backup of the entire 2TB NVMe SSD (`volume1`) onto the 8TB HDD RAID 1 array (`volume2`). This protects against a failure of the high-performance NVMe drive.

These are the settings configured within the Duplicati web interface for this specific job.

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

### 🚨 Full Disaster Recovery (Volume1 Failure)

This procedure covers a catastrophic failure of the primary NVMe SSD (`volume1`). It assumes you have physically replaced the drive and that your **core services** (AdGuard, Caddy, Duplicati) have their configuration data on `volume2`, making them recoverable *before* restoring `volume1`.

!!! warning "Precautionary Step: DNS"
    The following steps may require the NAS to download Docker images from the internet. To prevent a DNS dependency loop (where the NAS can't resolve addresses because AdGuard isn't running yet), it is safest to perform this initial step.

**Recovery Sequence:**

1. **Temporarily Reconfigure Router DNS:**
    * Log into your network router's administration page.
    * Change the primary DNS server from the AdGuard Home IP (`192.168.50.2`) to a public DNS provider (e.g., `1.1.1.1` or your ISP's default).
    * This ensures the NAS has reliable internet access for the next steps.

2. **Start Core DNS Service (AdGuard Home):**
    * Your `start-all.sh` script is designed to ignore AdGuard Home to prevent accidental downtime. Therefore, it must be started independently.
    * Connect to your NAS via SSH.
    * Navigate to the scripts directory and use the `update.sh` script to cleanly start AdGuard:

        ```bash
        cd /volume2/docker/mistia-nexus/scripts
        update.sh adguard-home
        ```

3. **Start Remaining Core Services:**
    * With DNS running, start all other core infrastructure services (Caddy, Duplicati, etc.).
    * From the same `scripts` directory, run the `start-all.sh` script. It will safely ignore the already-running AdGuard container.

        ```bash
        start-all.sh
        ```

    * You can now access the Duplicati web UI via its standard address (`https://duplicati.mistia.xyz`).

4. **Restore Normal DNS Operation:**
    * At this point, all core services are running, including AdGuard. You can now safely revert your router's DNS settings.
    * Log back into your router and change the primary DNS server back to your AdGuard Home IP (`192.168.50.2`).
    * Your network is now operating normally while the data restore proceeds.

5. **Restore `volume1` from Backup:**
    * Access the Duplicati web UI.
    * Your `Mistia-Nexus-App-Backup` job will be present. Click the **"Restore"** button for that job.
    * Select the latest backup version.
    * For restore options, choose **"Original location"** and **"Overwrite"** to ensure a clean restore onto the new empty volume.
    * Click **"Restore"** and wait for the process to complete.

6. **Start Data-Dependent Applications:**
    * Once the restore is complete, you can start any applications that rely on the restored `volume1` data.

### 💥 Disaster Recovery (Total NAS Failure)

This is the most severe scenario, assuming the entire NAS hardware has failed and been replaced. You are starting with a new NAS and your external HDD backup of `volume2`.

This is a **two-phase recovery**. You must first restore the foundational `volume2` using a temporary tool, then use the tools on that restored foundation to recover `volume1`.

#### Phase 1: Restore `volume2` from External HDD

**Goal:** To decrypt and restore the contents of your external HDD backup onto the new, blank `volume2`.

1. **Prepare New NAS:**
    * Install the UGREEN OS on the new hardware.
    * Create Storage Pool 1 (`volume1`) on the NVMe drive.
    * Create Storage Pool 2 (`volume2`) on the HDD RAID array.
    * Install the Docker application from the App Center. This creates the necessary (but empty) `@docker` and `docker` folders on `volume1`.

2. **Connect External HDD:**
    * Plug your external HDD backup directly into a USB port on the new NAS. The NAS will mount it automatically (e.g., at a path like `/run/media/usb-drive`).

3. **Launch Temporary Duplicati Container:**
    * Connect to your new NAS via SSH.
    * Execute the following `docker run` command to start a temporary Duplicati instance. This instance is clean and does not use any of your existing project configurations.

        ```bash
        docker run --rm -it \
          -p 8200:8200 \
          -v /path/to/external-hdd:/source_backup \
          -v /volume2:/restore_destination \
          duplicati/duplicati:latest
        ```

    * **Note:** Replace `/path/to/external-hdd` with the actual mount point of your USB drive.

4. **Perform `volume2` Restore:**
    * On your desktop computer, open a web browser to `http://<new-nas-ip>:8200`.
    * Click `Restore` >> `Direct restore from backup files`.
    * **Backend (Storage Type):** `Local folder or drive`
    * **Path:** `/source_backup` (This is the path *inside* the temporary container).
    * **Encryption:** Enter the **encryption passphrase** for your external HDD backup.
    * **Restore to:** Select "Restore to a different location" and enter the path `/restore_destination`.
    * Click **"Restore"**. Duplicati will decrypt the backup and write the original files (your `mistia-nexus` project, scripts, and the `volume1` backup data) to `volume2`.

5. **Clean Up:**
    * Once the restore is complete, go back to your SSH terminal and press `Ctrl+C` to stop and automatically remove the temporary Duplicati container.

#### Phase 2: Restore `volume1`

At the end of Phase 1, your new NAS is in the exact same state as a NAS that has only suffered a `volume1` failure.

Proceed with the **Full Disaster Recovery (Volume1 Failure)** plan outlined above.
