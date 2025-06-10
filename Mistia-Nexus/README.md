# Mistia-Labs Homelab Automation

This repository contains the Infrastructure as Code (IaC) to automatically deploy and manage Docker services on a Ugreen NAS.

The core of this automation is the `install/setup.sh` script, which handles package installation, repository cloning, and service deployment **securely**.

## 1. Prerequisites (Manual Steps)

Before running the automated installer, you must complete these three manual steps.

1. **Initial System Setup:**
    * Complete the UGOS Pro setup wizard.
    * Configure your Storage Pools: `Volume 1` (NVMe) and `Volume 2` (HDD).
    * Set a static IP address for the NAS.
    * Create your main administrative user account.

2. **Generate a GitHub Personal Access Token (PAT):**
    * To clone this private repository, you need a PAT.
    * Follow the [GitHub documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) to create a **classic** token.
    * **You only need to grant the `repo` scope.**
    * **Copy the generated token and have it ready to paste.** Do NOT save it in any file inside this repository.

3. **Configure `setup.sh`:**
    * Open the `install/setup.sh` file in this repository.
    * Find the `NAS_USER` variable at the top and change its value to your actual username on the Ugreen NAS.
    * Commit and push this change to your repository.

## 2. Automated Installation

This process will securely download and execute the setup script.

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

The script will now handle the rest of the setup automatically.

## 3. Post-Installation

The script handles the technical setup, but you still need to configure the applications themselves.

* **Portainer:** Access at `https://mistia-nexus.local:9444` to create your admin account and view your Docker environment.
* **Duplicati:** Access at `http://mistia-nexus.local:8200` to configure your backup jobs (NVMe to HDD, PC to NAS, etc.).

## 4. Ongoing Management

For daily management, `cd` into the deployment directory (`/volume2/docker`) and use the provided scripts:

* `./start_all.sh`: Starts all services.
* `./stop_all.sh`: Stops all services.
* `./update_all.sh`: Pulls the latest Docker images and restarts the services.
