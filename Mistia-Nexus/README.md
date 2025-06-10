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
    # --- Installer Bootstrap ---

    # 1. Securely ask for your GitHub Personal Access Token
    read -sp 'Paste your GitHub PAT and press Enter: ' GITHUB_TOKEN
    printf "\n"

    # 2. Download the installer script using the token for authentication
    curl -sL -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      "https://raw.githubusercontent.com/late4ever/Mistia-Labs/main/install/setup.sh" \
      -o setup.sh

    # 3. Make the script executable
    chmod +x setup.sh

    # 4. Run the installer script, passing the token to it so you aren't asked again
    ./setup.sh "${GITHUB_TOKEN}"

    # --- End of Bootstrap ---
    ```

The script will now handle the rest of the setup automatically.

## 3. Post-Installation

... (This section remains the same) ...

## 4. Ongoing Management

... (This section remains the same) ...
