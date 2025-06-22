---
icon: material/file-cloud
---

# :material-file-cloud: FileCloud

<!-- markdownlint-disable MD033 -->

!!! abstract "Overview"
    FileCloud is a self-hosted file sharing and synchronization platform, similar to Dropbox or ownCloud. It allows for connecting to existing file shares (like SMB) and providing a modern, web-based interface for access, sharing, and remote collaboration without migrating your data.

## 📑 Service Information

:material-web: [https://filecloud.mistia.xyz](https://filecloud.mistia.xyz)

:fontawesome-regular-id-badge: filecloud &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: filecloud/filecloud-server:latest

:fontawesome-regular-id-badge: filecloud-db &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: mongo:6.0

:fontawesome-regular-id-badge: filecloud-solr &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: filecloud/solr:8.11

| Container | Host Ports | Container Ports | Network | Host Path / Docker Volume | Container Path |
|:---------:|:----------:|:---------------:|:-------:|:-------------------------:|:--------------:|
| filecloud | *proxied* | `80` | `filecloud-net`<br>`mistia-proxy-net` | `/volume1/docker/filecloud/server/data`<br>`/volume1/docker/filecloud/server/logs` | `/var/www/html/data`<br>`/var/log/httpd` |
| filecloud-db | `N/A` | `27017` | `filecloud-net` | `/volume1/docker/filecloud/db` | `/data/db` |
| filecloud-solr | `N/A` | `8983` | `filecloud-net` | `/volume1/docker/filecloud/solr` | `/var/solr` |

## 📋 Prerequisites

### 🌐 Network Requirements

The `mistia-proxy-net` network must be available.

### 🗂️ NVMe Storage

SSH into the NAS to create the required directories on the high-performance NVMe volume.

```bash
--8<-- "docs/content/.snippets/ssh.sh:ssh"
```

Create the required folders:

```bash
sudo mkdir -p /volume1/docker/filecloud/server/data
sudo mkdir -p /volume1/docker/filecloud/server/logs
sudo mkdir -p /volume1/docker/filecloud/db
sudo mkdir -p /volume1/docker/filecloud/solr
```

## 🔧 Configuration

### 📂 Host Directory

```text
/volume1/docker/filecloud/
├── server/
│   ├── data/
│   └── logs/
├── db/
└── solr/

mistia-nexus/
└── filecloud/
    ├── .env                # Application secrets
    └── docker-compose.yml  # Defines the FileCloud service, network, and volumes
```

### 🐋 Docker Compose

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/filecloud/docker-compose.yml"
```

### 🔀 Reverse Proxy

```Caddyfile title="Caddyfile"
--8<-- "mistia-nexus/caddy/Caddyfile:filecloud"
```

### 📄 Application Secrets

Create the `.env` file in the deployment location. This file stores credentials that should not be committed to the repository.

```bash
cd /volume2/docker/mistia-nexus/
./scripts/git-update.sh

cd /volume2/docker/mistia-nexus/filecloud
sudo nano .env
```

Add the following content to the `.env` file. Replace `[secret-here]` with strong, unique passwords.

```text title=".env"
#--- FileCloud Secrets ---
MONGO_INITDB_ROOT_USERNAME=filecloud
MONGO_INITDB_ROOT_PASSWORD=[secret-here]
FILECLOUD_ADMIN_USER=admin
FILECLOUD_ADMIN_PASSWORD=[secret-here]
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

```bash
chmod 600 .env
```

## ✨ Initial Deployment

```bash
cd /volume2/docker/mistia-nexus/
./scripts/add-service.sh filecloud
```

## 🚀 Initial Setup

### 📝 DNS Rewrite

1. Navigate to [https://adguard.mistia.xyz](https://adguard.mistia.xyz) >> `Filters` >> `DNS rewrites`
2. Click `Add DNS rewrite`
    * **Domain**: `filecloud.mistia.xyz`
    * **Answer**: `192.168.50.4`
    * Click `Save`
3. Navigate to [https://filecloud.mistia.xyz](https://filecloud.mistia.xyz) to verify. You may need to wait a few minutes for the service to be fully available on first launch.

### 🪪 Account Setup & License

1. Navigate to [https://filecloud.mistia.xyz](https://filecloud.mistia.xyz) and log in with the admin credentials you defined in the `.env` file (`admin` / `[secret-here]`).
2. You will be prompted to install a license. Go to the [FileCloud Community Edition page](https://www.filecloud.com/community-edition/) to register for a free license key (`license.xml`).
3. In the FileCloud admin portal, navigate to `Settings` >> `License` and upload the `license.xml` file.

### 🔗 Connect to SMB Shares

This is the key step to connect your existing UGREEN NAS folders to FileCloud without moving any data.

1. In the FileCloud admin portal, navigate to `Settings` >> `Storage`.
2. Click the **Add Network Folder** button.
3. Fill in the details for your SMB share:
    * **Display Name:** A friendly name for the folder (e.g., `Shared Documents`).
    * **Network Folder Path:** The UNC path to your SMB share. Since the FileCloud container is on the same host as the NAS, you can use the NAS's IP address: `\\192.168.50.4\your-share-name` (e.g., `\\192.168.50.4\Documents`).
    * **Login Name:** The username for a NAS account that has permission to access the SMB share.
    * **Login Password:** The password for that NAS account.
4. Click **Add**. The network folder will now be available to users in FileCloud.
5. Repeat this process for any other SMB shares you wish to make available.
