---
icon: material/console
---

# ⚡ Management Commands

!!! abstract "Overview"
    Management commands for all common Mistia Labs operations

## :material-nas: Mistia Nexus

### 🔑 SSH into the NAS

!!! note "SSH Key"
    SSH Key has been setup. Unlock Bitwarden app to use as SSH agent.

```bash
--8<-- "docs/content/.snippets/ssh.sh:ssh"
```

### 📁 Directory

```text
/volume1/               # NVMe volume for Applications

/volume2/               # HDD raid volume for Data
├── Backups/            # Main backup location  
├── Mistia/             # Main cloud files
└── docker/             
    └── mistia-nexus/   # Mistia Labs deployment
```

### ⚙️ Service Management

!!! note "Operating Directory"
    This is assume to be in `/volume2/docker/mistia-nexus`

#### Start All Services

This script starts all non-critical services defined in the `mistia-nexus` directory. It intelligently detects the active proxy service (Caddy or Nginx-Proxy) and starts it first to ensure proper routing for other services. Services with a `.critical` or `.ignore` file in their directory will be skipped.

??? example "start-all.sh"
    ```bash
    --8<-- "mistia-nexus/scripts/start-all.sh"
    ```

```bash
# Start all services
./scripts/start-all.sh
```

#### Stop All Services

This script gracefully stops all non-critical services. It identifies the active proxy and stops it last to prevent connection errors for services that might depend on it. Services with a `.critical` file in their directory will be skipped.

??? example "stop-all.sh"
    ```bash
    --8<-- "mistia-nexus/scripts/stop-all.sh"
    ```

```bash
# Stop all services (respects .critical files)
./scripts/stop-all.sh
```

#### Update All Services

This script performs a comprehensive update of the entire stack. It stops all services, syncs with the latest code from the Git repository, pulls or builds the newest Docker images for services that are not ignored (via `.critical` or `.ignore` files), and then restarts everything.

??? example "update-all.sh"
    ```bash
    --8<-- "mistia-nexus/scripts/update-all.sh"
    ```

```bash
# Update all services (stop-all.sh, git fetch, docker compose pull, start-all.sh)
./scripts/update-all.sh
```

#### Update Single Service

Use this script to update a specific service without affecting the rest of the stack. It's useful for targeted updates or when a service's configuration has changed.

!!! note "Update Critical Service"
    Use this to update service that was tagged with .critical

??? example "update.sh"
    ```bash
    --8<-- "mistia-nexus/scripts/update.sh"
    ```

```bash
# Update single service (e.g., jellyfin)
./scripts/update.sh jellyfin
```

#### Add New Service

This script adds a new service to the running stack without requiring a full restart. It fetches the latest configuration from Git, verifies the new service directory, updates the active reverse proxy, and then starts the new service.

??? example "add-service.sh"
    ```bash
    --8<-- "mistia-nexus/scripts/add-service.sh"
    ```

```bash
# Add a new service (e.g., jellyfin)
./scripts/add-service.sh jellyfin
```

#### Git Update

This script manually syncs the local deployment with the `main` branch of the Git repository, ensuring all scripts and configurations are up-to-date.

??? example "git-update.sh"
    ```bash
    --8<-- "mistia-nexus/scripts/git-update.sh"
    ```

```bash
# Update the entire stack from Git
./scripts/git-update.sh
```

#### Verify Backups

This script runs a full backup and restore cycle for a test file to verify the integrity of the Duplicati backup configuration. It requires the encryption passphrase to run.

??? example "verify-backup.sh"
    ```bash
    --8<-- "mistia-nexus/scripts/verify-backup.sh"
    ```

```bash
# Verify the latest backup
./scripts/verify-backup.sh
```
