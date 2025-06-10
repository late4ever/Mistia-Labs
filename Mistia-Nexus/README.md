# Mistia-Labs Homelab Automation

This repository contains the Infrastructure as Code (IaC) to automatically deploy and manage Docker services on a Ugreen NAS.

The core of this automation is the `install/setup.sh` script, which handles package installation, repository cloning, and service deployment.

## 1. Prerequisites (Manual Steps)

Before running the automated installer, you must complete these three manual steps on your NAS.

1. **Initial System Setup:**
    * Complete the UGOS Pro setup wizard.
    * Configure your Storage Pools: `Volume 1` (NVMe) and `Volume 2` (HDD).
    * Set a static IP address for the NAS.
    * Create your main administrative user account.

2. **Generate a GitHub Personal Access Token (PAT):**
    * To clone this private repository, you need a PAT.
    * Follow the [GitHub documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) to create a **classic** token.
    * **You only need to grant the `repo` scope.**
    * Copy the generated token and save it somewhere secure. You will need it to run the setup script.

## 2. Automated Installation

This single command will download and execute the setup script, automating the entire deployment.

1. **Connect to your NAS via SSH:**

    ```bash
    ssh late4ever@mistia-nexus.local -p 22
    ```

2. **Run the Installer:**
    * **Before pasting**, you must open the `install/setup.sh` file in your GitHub repository and **edit the configuration variables** at the top with your own `GIT_USER`, `GIT_REPO`, `GIT_PAT`, `NAS_USER`, etc.
    * Once edited, paste this clean command into your SSH session and press Enter:

    ```bash
    bash <(curl -sL https://raw.githubusercontent.com/late4ever/Mistia-Labs/main/Install/setup.sh)
    ```

The script will now run and perform all necessary setup steps.

## 3. Post-Installation

The script handles the technical setup, but you still need to configure the applications themselves.

* **Portainer:** Access at `https://mistia-nexus.local:9444` to create your admin account and view your Docker environment.
* **Duplicati:** Access at `http://mistia-nexus.local:8200` to configure your backup jobs (NVMe to HDD, PC to NAS, etc.).

## 4. Ongoing Management

For daily management, `cd` into the deployment directory (`/volume2/docker`) and use the provided scripts:

* `./start_all.sh`: Starts all services.
* `./stop_all.sh`: Stops all services.
* `./update_all.sh`: Pulls the latest Docker images and restarts the services.