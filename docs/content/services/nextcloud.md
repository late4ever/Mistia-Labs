---
icon: simple/nextcloud
---

# :simple-nextcloud:{ .nextcloud } Nextcloud

<!-- markdownlint-disable MD033 -->

!!! abstract "Overview"
    Nextcloud is a self-hosted file sync and collaboration platform that replaces Dropbox and Google services. With Calendar and Contacts apps enabled, it provides complete family organization including file storage, automatic photo sync, shared calendars, and contact synchronization across all devices.

## 📑 Service Information

:material-web: [https://nextcloud.mistia.xyz](https://nextcloud.mistia.xyz)

:fontawesome-regular-id-badge: nextcloud &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: nextcloud:apache

:fontawesome-regular-id-badge: nextcloud-cron &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: nextcloud:apache

:fontawesome-regular-id-badge: nextcloud-db &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: mariadb:latest

:fontawesome-regular-id-badge: nextcloud-redis &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: redis:alpine

| Container | Host Ports | Container Ports | Network | Host Path / Docker Volume | Container Path |
|:---------:|:----------:|:---------------:|:-------:|:-------------------------:|:--------------:|
| nextcloud | *proxied* | `80` | `nextcloud-net`<br>`mistia-proxy-net` | `/volume1/docker/nextcloud/data`<br>`/volume1/docker/nextcloud/config` | `/var/www/html`<br>`/var/www/html/config` |
| nextcloud-cron | `N/A` | `80` | `nextcloud-net` | `/volume1/docker/nextcloud/data`<br>`/volume1/docker/nextcloud/config` | `/var/www/html`<br>`/var/www/html/config`|
| nextcloud-db | `N/A` | `3306` | `nextcloud-net` | `/volume1/docker/nextcloud/db` | `/var/lib/mysql` |
| nextcloud-redis | `N/A` | `6379` | `nextcloud-net` | `/volume1/docker/nextcloud/redis` | `/data` |

## 📋 Prerequisites

### 🌐 Network Requirements

The `mistia-proxy-net` network must be available.

### 🗃️ External Storage Requirements

- **NAS Shared folders**: `/volume2/Mistia/` with subdirectories for Videos, Photos, Documents etc
- **NAS User folders**: `/home/` with user-specific subdirectories (`/home/late4ever/`, `/home/mistsoya/`)

### 🗂️ NVMe Storage

SSH into the NAS to create the NVMe volume

```bash
--8<-- "docs/content/.snippets/ssh.sh:ssh"
```

```bash
sudo mkdir -p /volume1/docker/nextcloud/data
sudo mkdir -p /volume1/docker/nextcloud/config
sudo mkdir -p /volume1/docker/nextcloud/db
sudo mkdir -p /volume1/docker/nextcloud/redis
```

## 🔧 Configuration

### 📂 Host Directory

```text
/volume1/docker/nextcloud/
├── data/      # Application files
├── config/    # Configuration files
├── db/        # MariaDB database files
└── redis/     # Redis cache

mistia-nexus/
└── nextcloud/
    ├── .env                # Application secrets
    └── docker-compose.yml  # Defines the Nextcloud service, network, and volumes
```

### 📁 Container Directory

#### nextcloud

```text
/var/www/html/          # Application files
/var/www/html/config/   # Configuration and cache
```

#### nextcloud-cron

```text
/var/www/html/          # Application files
/var/www/html/config/   # Configuration and cache
```

#### nextcloud-db

```text
/var/lib/mysql/         # Database files
```

#### nextcloud-redis

```text
/data/                  # Cache and session data
```

### 🐋 Docker Compose

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/nextcloud/docker-compose.yml"
```

### 🐋 Dockerfile

```Dockerfile title="Dockerfile"
--8<-- "mistia-nexus/nextcloud/Dockerfile"
```

### 🔀 Reverse Proxy

```Caddyfile title="Caddyfile"
--8<-- "mistia-nexus/caddy/Caddyfile:nextcloud"
```

### 📄 Application Secrets

```bash
cd /volume2/docker/mistia-nexus/
./scripts/git-update.sh

cd /volume2/docker/mistia-nexus/nextcloud
sudo nano .env
```

```text title=".env"
DB_PASSWORD=[secret-here]
DB_ROOT_PASSWORD=[secret-here] 
ADMIN_USER=late4ever
ADMIN_PASSWORD=[secret-here]
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

### 🚀 Service Deployment

```bash
cd /volume2/docker/mistia-nexus/
./scripts/add-service.sh nextcloud
```

## 🚀 Initial Setup

### 📝 DNS Rewrite

1. Navigate to [https://adguard.mistia.xyz](https://adguard.mistia.xyz) >> `Filters` >> `DNS rewrites`

2. Click `Add DNS rewrite`
      - **Domain**: `nextcloud.mistia.xyz`
      - **Answer**: `192.168.50.4`
      - Click `Save`

3. Navigate to [https://nextcloud.mistia.xyz](https://nextcloud.mistia.xyz) to verify

### 🪪 Account Setup

1. Navigate to [https://nextcloud.mistia.xyz](https://nextcloud.mistia.xyz)

2. The admin account will be automatically created using the credentials from `.env`

3. Create additional user accounts for family members:
   - Navigate to `Users` settings
   - Add user accounts for each family member

### 🪖 System Configuration

#### Server Maintenance Window

```bash
--8<-- "docs/content/.snippets/ssh.sh:ssh"
```

Set maintenance window to be 1 to 3am

```bash
docker exec nextcloud php occ config:system:set maintenance_window_start --type=integer --value=1
docker exec nextcloud php occ config:system:set maintenance_window_end --type=integer --value=3
```

1. Navigate to [Nextcloud >> Administration Settings >> Basic Settings](https://nextcloud.mistia.xyz/settings/admin)

2. **Set Background Jobs** to `Cron`

#### Run Maintenance Tasks

```bash
docker exec nextcloud php occ maintenance:repair --include-expensive
```

#### Set Default Phone Region

```bash
docker exec nextcloud php occ config:system:set default_phone_region --value="SG"
```

#### Email Configuration

1. Navigate to [Nextcloud >> Personal settings >> Personal Info](https://nextcloud.mistia.xyz/settings/user)

2. Set **Email** field

3. Navigate to [Nextcloud >> Administration Settings >> Basic Settings](https://nextcloud.mistia.xyz/settings/admin)

4. **Email Server**
    - **Send mode:** `SMTP`
    - **Encryption:** `SSL`
    - **From address:** `[username]+nextcloud` @ `[domain.com]`
    - **Server address:** `smtp.[domain.com]` @ [465]
    - Check **Authentication required**
    - **Credential:** `[username]@[domain.com]` `[app password]`
    - Click `Save`

### 🗂️ External Storage Configuration

1. Navigate to [Nextcloud >> Apps >> Dsiabled apps](https://nextcloud.mistia.xyz/settings/apps/disabled)

2. Click `Enable` for ***External storage support*

3. Navigate to [Nextcloud >> Administration settings >> External storage](https://nextcloud.mistia.xyz/settings/admin/externalstorages)

4. Add SMB Share:
   - **Folder name**: `Folder Name` or `/` to take over as root files view
   - **External storage**: `SMB/CIFS`
   - **Authenticaion**: `Manually enterd, stored in database`
   - **Configuration**:
     - `Mistia-Nexus`
     - `[personal folder name]`
   - **Available for**: `nextcloud user`

   - **Folder name**: `/` to take over as root files view
   - **External storage**: `SMB/CIFS`
   - **Authenticaion**: `Manually enterd, stored in database`
   - **Configuration**:
     - `Mistia-Nexus`
     - `Mistia`
   - **Available for**: `All people`

### 📱 Mobile Setup

#### File Sync (Nextcloud App)

1. Install **Nextcloud** app from App Store/Play Store

2. Configure connection:
   - **Server**: `https://nextcloud.mistia.xyz`
   - **Username**: Your Nextcloud username
   - **Password**: Your Nextcloud password

3. Enable **Auto Upload** for photos and videos:
   - Go to `Settings` in the app
   - Enable `Auto upload`
   - Select folders to upload to (e.g., `Shared Photos`)

#### Calendar Sync (CalDAV)

**Android:**

```text
Settings → Accounts → Add account → CalDAV
Server: https://nextcloud.mistia.xyz/remote.php/dav/
Username: [your-nextcloud-username]
Password: [your-nextcloud-password]
```

#### Contact Sync (CardDAV)

**Android:**

```text
Settings → Accounts → Add account → CardDAV
Server: https://nextcloud.mistia.xyz/remote.php/dav/
Username: [your-nextcloud-username]
Password: [your-nextcloud-password]
```

### 📧 Contact Migration from Google

1. **Export from Google Contacts**:
   - Go to [contacts.google.com](https://contacts.google.com)
   - Click `Export` → `vCard format`
   - Download the vCard file

2. **Import to Nextcloud**:
   - Navigate to `Contacts` app in Nextcloud
   - Click `Import contacts`
   - Upload the vCard file
   - Select the address book to import to

3. **Setup device sync**:
   - Remove Google account from Contacts sync on devices
   - Add Nextcloud CardDAV account (see above)
   - Your contacts will now sync with Nextcloud
