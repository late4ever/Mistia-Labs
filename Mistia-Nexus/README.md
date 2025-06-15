# Mistia-Nexus: Homelab as Code Guide

This guide contains the complete instructions for deploying and managing all Docker services on the Mistia-Nexus NAS using a fully automated, version-controlled system.

## Core Architectural Concepts

Understanding these concepts is key to managing this homelab effectively.

* **Shared Proxy Network:** All primary application containers are attached to a single Docker bridge network called `mistia-proxy-net`. This allows the reverse proxy to communicate with services securely and efficiently without exposing their ports on the host machine.
* **Secrets Management:** All secrets (passwords, API tokens) are managed using `.env` files, which are specific to each service directory and are excluded from Git. This ensures no sensitive data is ever stored in the repository.
* **Critical Service Isolation:** Core infrastructure like AdGuard Home is intentionally isolated from mass operations. By placing an empty `.ignore` file in its directory, the `update_all.sh` and `stop_all.sh` scripts will skip it, preventing network-wide outages during application updates.

---

## Section 1: First-Time System Setup

This procedure will take a bare NAS and deploy the entire homelab stack.

### Part A: Manual Prerequisites

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

### Part B: Automated Installation

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

3. **Log Out and Log Back In:**

    ```bash
    exit
    ssh late4ever@mistia-nexus.local
    ```

### Part C: Create Application Secrets

1. **Navigate to Deployment Directory:**

    ```bash
    cd /volume2/docker/Mistia-Nexus
    ```

2. **Create `.env` files** for each service that requires secrets.

    **For Caddy:**

    ```bash
    cd caddy
    nano .env
    # Add your Cloudflare Token
    # CLOUDFLARE_API_TOKEN=YourSecretCloudflareToken
    # CADDY_EMAIL=email@domain.com
    # Save the file and exit (`Ctrl+X`, `y`, `Enter`)
    cd ..
    ```

    **For Nginx Proxy Manager:**

    ```bash
    cd nginx-proxy
    nano .env
    # Add your Cloudflare Token
    # CLOUDFLARE_API_TOKEN=YourSecretCloudflareToken
    # Save the file and exit (`Ctrl+X`, `y`, `Enter`)
    cd ..
    ```

    **For Duplicati:**

    ```bash
    cd duplicati
    nano .env
    # Add your Nginx credentials
    # DB_PASSWORD=YourStrongProxyDBPassword
    # DB_ROOT_PASSWORD=YourStrongDBRootPassword
    # Save the file and exit (`Ctrl+X`, `y`, `Enter`)
    cd ..
    ```

### Part D: Deploy the Stack

1. **Run the Start Script:** From the `Mistia-Nexus` root, run the `start_all.sh` script.

    ```bash
    # This will start all core services.
    ./scripts/start_all.sh
    ```

    Your homelab is now online.

### Part E: Post-Installation

* **Portainer:** Access at [`https://portainer.mistia.xyz`](https://portainer.mistia.xyz) to create your admin account and view your Docker environment.
* **Duplicati:** Access at [`https://duplicati.mistia.xyz`](https://duplicati.mistia.xyz) to configure your backup jobs.
* **Ngnix Proxy Manager:** Access at [`https://proxy.mistia.xyz`](https://proxy.mistia.xyz) to create your admin account and setup proxies.
* **AdGuard Home** Access at [`https://adguard.mistia.xyz`](https://adguard.mistia.xyz) to create your admin account and setup the configurations.

---

## Section 2: Daily Operations & Management

All management is performed using the scripts in the `/scripts` directory.

```bash
ssh late4ever@mistia-nexus.local
cd /volume2/docker/Mistia-Nexus
```

| Script | Usage | Purpose |
| :--- | :--- | :--- |
| `start_all.sh` | `./scripts/start_all.sh` | Starts the entire application stack. |
| `stop_all.sh`| `./scripts/stop_all.sh` | Stops all non-ignored services. |
| `update_all.sh`| `./scripts/update_all.sh` | Performs a full stack update: stops services, syncs Git, pulls all images, and restarts the stack. |
| `update.sh` | `./scripts/update.sh <service>` | Updates a single, specific service (e.g., `portainer`). |
| `add_service.sh`| `./scripts/add_service.sh <new_service_name>`| Adds a new service (e.g., `jellyfin`) to the running stack without a full restart. |
| `verify_backup.sh`| `./scripts/verify_backup.sh` | Runs an automated backup and restore test for Duplicati. |

---

### Section 3: SOP

#### Adding a New Service

This procedure uses the `add_service.sh` script for a zero-downtime deployment.

1. **Prepare Locally:**
    * Create the new service directory (e.g., `Mistia-Nexus/jellyfin/`).
    * Create the `docker-compose.yml` for the new service. Ensure it connects to the `mistia-proxy-net` as an external network.
    * Update your `caddy/Caddyfile` to add the new reverse proxy route for the service.
2. **Commit & Push:** `git add .`, `git commit`, and `git push` your changes.
3. **Deploy on NAS:**
    * SSH into your NAS and `cd` to `/volume2/docker/Mistia-Nexus`.
    * Run the `add_service.sh` script, specifying the new service and your active proxy.

        ```bash
        # This syncs git, updates caddy, and starts jellyfin.
        ./scripts/add_service.sh jellyfin
        ```

#### Updating the Documentation

After adding a service, update the root `README.md` file's service table and any other relevant documentation, then commit and push the changes.

---

### 4: Teardown

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

### 5: Restore Testing

#### Automating with Cron (Advanced)

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
