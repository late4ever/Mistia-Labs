# Mistia-Nexus Infrastructure as Code Guide

This repository contains the Infrastructure as Code (IaC) to automatically deploy and manage Docker services on a UGREEN NASync.

This guide uses a secure bootstrap method for initial setup and `.env` files for managing application secrets, ensuring no passwords or keys are ever committed to the repository.

## 1. Prerequisites (Manual Steps)

Before you begin, complete these three manual steps on your NAS.

1. **Initial UGREEN NASync Setup:**
   * `Storage Pool 1` (NVMe: Application)
      * `Volume 1`
   * `Storage Poo1 2` (HDD: Data)
      * `Volume 2`

   * Set a static IP address and custom domain for the NAS.
   * Create your main administrative user account.

2. **Generate a GitHub Personal Access Token (PAT):**
    * To clone this private repository, you need a PAT.
    * Follow the [GitHub documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) to create a **classic** token.
    * You only need to grant the `repo` scope.
    * Copy the generated token and have it ready to paste.

3. **Configure `setup.sh`:**
    * Open the `/Install/setup.sh` file in this repository.
    * Find the `NAS_USER` and `NAS_GROUP` variables at the top and change their values to match your own.

        ```bash
        # To find out the user id and group id
        ssh late4ever@mistia-nexus.local
        id <admin account create above>
        ```

    * Commit and push this change to your repository.

## 2. Automated Installation

The installation is a three-part process: preparing the system, creating your secrets, and deploying the containers.

### Part A: Prepare the System

1. **Connect to your NAS via SSH:**

    ```bash
    ssh late4ever@mistia-nexus.local
    ```

2. **Run the Installer Bootstrap:**
    * Copy the **entire multi-line block of commands** below and paste it into your SSH session.
    * You will be prompted once to securely enter your PAT.

        ```bash
        read -sp 'Paste your GitHub PAT and press Enter: ' GITHUB_TOKEN
        printf "\n"
        curl -sL -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        "https://raw.githubusercontent.com/late4ever/Mistia-Labs/main/Install/setup.sh" \
        -o setup.sh
        chmod +x setup.sh
        ./setup.sh "${GITHUB_TOKEN}"
        ```

    * The script will run and finish by instructing you to log out.

### Part B: Create Application Secrets

Before starting the containers, you must create the secret `.env` file for all required services.

1. **Log Out & Log Back In:** As instructed by the script, close your SSH session and start a new one to apply your new Docker group permissions.

    ```bash
    exit
    ssh late4ever@mistia-nexus.local
    ```

2. **Create the individual services secret file:**

    ---

   **Duplicati**
      * Navigate to the `duplicati` directory:

        ```bash
        cd /volume2/docker/Mistia-Nexus/duplicati
        nano .env
        ```

      * Inside the editor, add the following lines. Replace `YourSuperSecretKeyHere` and `YourChosenUIPassword` with the correct value.

        ```txt
        DUPLICATI_SETTINGS_KEY=YourSuperSecretKeyHere
        DUPLICATI_UI_PASSWORD=YourChosenUIPassword
        ```

      * Save the file and exit (`Ctrl+X`, `y`, `Enter`).

    ---

    **Nginx Proxy Manager**
      * Navigate to the `nginx-proxy` directory:

        ```bash
        cd /volume2/docker/Mistia-Nexus/duplicati
        nano .env
        ```

      * Inside the editor, add the following lines. Replace `YourStrongProxyDBPassword` and `YourStrongDBRootPassword` with the correct value.

        ```txt
        DB_PASSWORD=YourStrongProxyDBPassword
        DB_ROOT_PASSWORD=YourStrongDBRootPassword
        ```

      * Save the file and exit (`Ctrl+X`, `y`, `Enter`).

    ---

### Part C: Deploy the Containers

1. **Run the Start Script:** Navigate to the main deployment directory and run the `start_all.sh` script to launch your Docker containers for the first time.

    ```bash
    cd /volume2/docker/Mistia-Nexus
    ./start_all.sh
    ```

    Your containers will now start up correctly.

## 3. Post-Installation

* **Portainer:** Access at [`https://mistia-nexus.local:9444`](https://mistia-nexus.local:9444) to create your admin account and view your Docker environment.
* **Duplicati:** Access at [`http://mistia-nexus.local:8200`](http://mistia-nexus.local:8200) to configure your backup jobs.
* **Ngnix Proxy Manager:** Access at [`http://mistia-nexus.local:81`](http://mistia-nexus.local:81) to create your admin account and setup proxies.

## 4. Ongoing Management

For daily management, `cd` into the deployment directory (`/volume2/docker/Mistia-Nexus`) and use the provided scripts:

* `./start_all.sh`: Starts all services.
* `./stop_all.sh`: Stops all services.
* `./update_all.sh`: Stops all containers, pulls the latest Docker images and restarts the services.

## 5. Teardown / Clean Up (For Fresh Testing)

If you need to completely reset your NAS to test the setup process from scratch, you can use the `teardown.sh` script.

**⚠️ WARNING: This is a destructive action and will permanently delete your Docker containers and configurations.**

1. **Connect to your NAS via SSH:**

    ```bash
    ssh late4ever@mistia-nexus.local
    ```

2. **Run the Teardown Bootstrap:**
    * This command will securely download and run the teardown script. It will ask for confirmation before deleting anything.

    ```bash
    read -sp 'Paste your GitHub PAT and press Enter: ' GITHUB_TOKEN
    printf "\n"
    curl -sL -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      "https://raw.githubusercontent.com/late4ever/Mistia-Labs/main/Install/teardown.sh" \
      -o teardown.sh
    chmod +x teardown.sh
    ./teardown.sh
    ```

This gives you a safe and repeatable way to both set up and tear down your homelab environment.

## 6. Automated Restore Testing

This document explains how to use the `verify_backup.sh` script to automatically test the integrity of your Duplicati backups.

### Purpose

A backup is useless if it can't be restored. This script provides an automated way to answer the question: "Can I decrypt and restore a file from my backup?"

The script performs the following actions:

1. Creates a temporary "canary" file with unique content inside your backup source directory.
2. Triggers the specified Duplicati backup job to run.
3. Restores only that single canary file to a temporary location.
4. Compares the restored file's content with the original content.
5. Reports **SUCCESS** or **FAILURE**.
6. Automatically cleans up all temporary files and folders, regardless of the outcome.

### How to Use the Script

1. **Place the Script:** Ensure `verify_backup.sh` is in your `Mistia-Nexus` deployment directory alongside your other management scripts.

2. **Make it Executable:** If you haven't already, run this command from your deployment directory:

    ```bash
    chmod +x verify_backup.sh
    ```

3. **Run the Test:** Execute the script. It will securely prompt you for the Duplicati encryption passphrase for the backup job you are testing.

    ```bash
    ./verify_backup.sh
    ```

### Automating with Cron (Advanced)

Running this script manually is great, but automating it provides continuous assurance. You can create a `cron` job to run this test weekly.

**Warning:** This method requires storing your Duplicati passphrase in a protected file on the NAS.

1. **Create a Passphrase File:**
    * Create a file that is only readable by you:

        ```bash
        echo "YourDuplicatiEncryptionPassword" > ~/.duplicati_pass
        chmod 600 ~/.duplicati_pass
        ```

2. **Modify the Script:**
    * Comment out the interactive `read` command in `verify_backup.sh` and add a line to read the password from your file:

        ```bash
        # read -sp 'Please enter the Duplicati ENCRYPTION PASSPHRASE for this backup: ' DUP_PASSPHRASE
        DUP_PASSPHRASE=$(cat ~/.duplicati_pass)
        ```

3. **Create the Cron Job:**
    * Open the cron table: `sudo crontab -e`
    * Add a line to run the script, for example, every Sunday at 6:00 AM. Make sure to redirect the output to a log file to review the results.

        ```bash
        0 6 * * 0    /volume2/docker/Mistia-Nexus/verify_backup.sh > /volume2/docker/Mistia-Nexus/verify_backup.log 2>&1
        ```

This creates a fully automated, hands-off system for continuously verifying the integrity of your most critical backups.
