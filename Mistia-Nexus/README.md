# Mistia-Labs Homelab Automation

This repository contains the Infrastructure as Code (IaC) to automatically deploy and manage Docker services on a Ugreen NAS.

This guide uses a secure bootstrap method for initial setup and `.env` files for managing application secrets, ensuring no passwords or keys are ever committed to the repository.

## 1. Prerequisites (Manual Steps)

Before you begin, complete these three manual steps on your NAS.

1. **Initial System Setup:**
    * Complete the UGOS Pro setup wizard.
    * Configure your Storage Pools: `Volume 1` (NVMe) and `Volume 2` (HDD).
    * Set a static IP address for the NAS (e.g., `mistia-nexus.local`).
    * Create your main administrative user account.

2. **Generate a GitHub Personal Access Token (PAT):**
    * To clone this private repository, you need a PAT.
    * Follow the [GitHub documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) to create a **classic** token.
    * **You only need to grant the `repo` scope.**
    * **Copy the generated token and have it ready to paste.**

3. **Configure `setup.sh`:**
    * Open the `Install/setup.sh` file in this repository.
    * Find the `NAS_USER` and `NAS_GROUP` variables at the top and change their values to match your own.
    * Commit and push this change to your repository.

## 2. Automated Installation

The installation is now a two-part process: preparing the system, then deploying the containers.

### Part A: Prepare the System

1. **Connect to your NAS via SSH:**

    ```bash
    ssh late4ever@mistia-nexus.local
    ```

2. **Run the Installer Bootstrap:**
    * Copy the **entire multi-line block of commands** below and paste it into your SSH session.
    * You will be prompted once to securely enter your PAT.

    ```bash
    # --- Installer Bootstrap ---
    read -sp 'Paste your GitHub PAT and press Enter: ' GITHUB_TOKEN
    printf "\n"

    curl -sL -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      "https://raw.githubusercontent.com/late4ever/Mistia-Labs/main/Install/setup.sh" \
      -o setup.sh

    chmod +x setup.sh

    ./setup.sh "${GITHUB_TOKEN}"
    ```

    The script will run and finish by instructing you to log out.

### Part B: Deploy the Containers

1. **Log Out & Log Back In:** As instructed by the script, close your SSH session and start a new one to apply your new Docker group permissions.

    ```bash
    exit
    ssh late4ever@mistia-nexus.local
    ```

2. **Run the Start Script:** Navigate to the deployment directory and run the `start_all.sh` script to launch your Docker containers for the first time.

    ```bash
    cd /volume2/docker
    ./start_all.sh
    ```

    Your containers will now start up correctly.

## 3. Post-Installation

* **Portainer:** Access at `https://mistia-nexus.local:9444` to create your admin account and view your Docker environment.
* **Duplicati:** Access at `http://mistia-nexus.local:8200` to configure your backup jobs.

## 4. Ongoing Management

For daily management, `cd` into the deployment directory (`/volume2/docker`) and use the provided scripts:

* `./start_all.sh`: Starts all services.
* `./stop_all.sh`: Stops all services.
* `./update_all.sh`: Pulls the latest Docker images and restarts the services.

---

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
