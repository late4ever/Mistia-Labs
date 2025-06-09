# My Ugreen NAS Homelab Setup

This repository contains the Infrastructure as Code (IaC) for deploying services on my Ugreen DXP4800+ NAS using Docker Compose. This guide serves as the disaster recovery runbook.

## 1. Initial NAS Setup (Manual Steps)

These steps must be completed on a fresh UGOS Pro installation before deploying the services.

1. **System Setup:**
    * Complete the initial UGOS Pro setup wizard.
    * Create Storage Pools and Volumes:
        * **Storage Pool 1 / Volume 1:** Your 2TB NVMe SSD.
        * **Storage Pool 2 / Volume 2:** Your 8TB HDD RAID 1 array.
    * Set a static IP address for your NAS via your router or in the UGOS Pro Network settings.

2. **User & Permissions:**
    * Create your main administrative user account.
    * Create a `Backups` Shared Folder located on `Volume 2`.
    * Grant your main user Read/Write permissions to the `Backups` share.

3. **Enable SSH:**
    * In the UGOS Pro Control Panel, go to **Terminal & SNMP**.
    * Enable the **SSH service**.

4. **Install System Tools via SSH:**
    * Connect to your NAS using a terminal:

        ```bash
        ssh your_username@<Your-NAS-IP-Address>
        ```

    * Install Docker, Docker Compose, and Git:

        ```bash
        sudo apt-get update
        sudo apt-get install -y docker.io docker-compose git
        ```

    * Add your user to the Docker group to manage Docker without `sudo` (requires logout/login to take effect):

        ```bash
        sudo usermod -aG docker $USER
        ```

    * Verify your user's PUID and PGID. You will need these for the `docker-compose.yml` files.

        ```bash
        id
        ```

        Look for `uid=1000` (PUID) and `gid=100` (PGID). Adjust the compose files if yours are different.

## 2. Deploying Services

1. **Clone This Repository:**
    * Clone this repository to a logical location on your resilient HDD array (`Volume 2`).

        ```bash
        # Navigate to Volume 2 and create a docker directory
        cd /volume2
        mkdir docker
        cd docker

        # Clone your repository
        git clone <URL_to_your_private_GitHub_repo> .
        ```

2. **Make Scripts Executable:**
    * From the `/volume2/docker` directory, run:

        ```bash
        chmod +x *.sh
        ```

3. **Deploy All Services:**
    * Run the start script:

        ```bash
        ./start_all.sh
        ```

    * The script will go into each subdirectory (`duplicati`, `portainer`) and launch the service defined in its `docker-compose.yml` file.

## 3. Service Details & Post-Deployment Setup

### Portainer

* **Purpose:** A powerful web interface to manage your Docker environment.
* **URL:** `https://<Your-NAS-IP-Address>:9444` (**Note the updated port**)
* **Setup:** On your first visit, you will be prompted to create an administrator account. Choose to manage the local Docker environment.

### Duplicati

* **Purpose:** Your automated backup solution.
* **URL:** `http://<Your-NAS-IP-Address>:8200`
* **Setup:**
    1. **Job 1 (NVMe to HDD):** Create a backup job to back up the source path `/nasroot/volume1/` to the destination path `/nasroot/volume2/Backups/NAS_Internal/NVMe_Apps/`. Schedule it to run daily.
    2. **Job 2 (PC to NAS):** Install Duplicati on your PC and configure it to back up to the network share `\\<Your-NAS-IP-Address>\Backups\PC_Backups\`.
    3. **Job 3 (NAS to External Drive):** When ready, create a job to back up important folders from `/nasroot/volume2/` (including `/nasroot/volume2/docker/`) to an external drive.

## 4. Management Scripts

All scripts should be run from the root directory of this repository (`/volume2/docker`).

* `./start_all.sh`: Starts all services.
* `./stop_all.sh`: Stops and removes all service containers (data in volumes is safe).
* `./update_all.sh`: Pulls the latest Docker images for all services and restarts them with the new versions.
