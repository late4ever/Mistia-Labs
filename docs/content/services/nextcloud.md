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

:fontawesome-regular-id-badge: nextcloud-db &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: mariadb:latest

:fontawesome-regular-id-badge: nextcloud-redis &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: redis:alpine

| Host Ports | Container Ports | Network | Host Path / Docker Volume | Container Path |
|:----------:|:---------------:|:-------:|:-------------------------:|:--------------:|
| *proxied* | `80` | `nextcloud-net`<br>`mistia-proxy-net` | `nextcloud_data`<br>`nextcloud_config`<br>`/volume2/Mistia`<br>`/home` | `/var/www/html`<br>`/var/www/html/config`<br>`/mnt/shared`<br>`/mnt/homes` |
| `N/A` | `3306` | `nextcloud-net` | `nextcloud_db_data` | `/var/lib/mysql` |
| `N/A` | `6379` | `nextcloud-net` | `nextcloud_redis_data` | `/data` |

## 📋 Prerequisites

### 🌐 Network Requirements

The `mistia-proxy-net` network must be available.

### 📁 External Storage Requirements

- **Shared folders**: `/volume2/Mistia/` with subdirectories for Videos, Photos, Documents etc
- **User folders**: `/home/` with user-specific subdirectories (`/home/late4ever/`, `/home/mistsoya/`)

## 🔧 Configuration

### 📂 Host Directory

```text
/volume1/docker
├── nextcloud_data          # Application files and cache
├── nextcloud_config        # Configuration and session data
├── nextcloud_db_data       # MariaDB database files
└── nextcloud_redis_data    # Redis cache and sessions

/
├── /volume2/Mistia/        # Shared folders
└── /home/                  # Personal user folders

mistia-nexus/
└── nextcloud/
    ├── .env                # Application secrets
    └── docker-compose.yml  # Defines the Nextcloud service, network, and volumes


```

### 📁 Container Paths

#### Nextcloud

```text
/var/www/html/          # Application files
/var/www/html/config/   # Configuration and cache
/mnt/shared/            # Shared folders
/mnt/homes/             # Personal user folders
```

#### Nextcloud-Db

```text
/var/lib/mysql/         # Database files
```

#### Nextcloud-Redis

```text
/data/                  # Cache and session data
```

### 🐋 Docker Compose

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/nextcloud/docker-compose.yml"
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

```bash
chmod 600 .env
```

### 🚀 Service Deployment

```bash
cd /volume2/docker/mistia-nexus/
./scripts/add-service.sh nextcloud
```

## 🚀 Initial Setup

### 🪪 Account Setup

1. Navigate to [https://nextcloud.mistia.xyz](https://nextcloud.mistia.xyz)

2. The admin account will be automatically created using the credentials from `.env`

3. Create additional user accounts for family members:
   - Navigate to `Users` settings
   - Add user accounts for each family member

### 📝 DNS Rewrite

1. Navigate to [https://adguard.mistia.xyz](https://adguard.mistia.xyz) >> `Filters` >> `DNS rewrites`

2. Click `Add DNS rewrite`
      - **Domain**: `nextcloud.mistia.xyz`
      - **Answer**: `192.168.50.4`
      - Click `Save`

3. Navigate to [https://nextcloud.mistia.xyz](https://nextcloud.mistia.xyz) to verify

### 🗂️ External Storage Configuration

1. Navigate to `Settings` >> `Administration` >> `External storage`

2. Add **Personal Folders** storage:
   - **Folder name**: `Personal Files`
   - **External storage**: `Local`
   - **Configuration**: `/mnt/homes/$user`
   - **Available for**: `All users`
   - **Enable User Variables**: ✓
   - **Allow sharing**: ✗ (keeps personal files private)

3. Add **Shared Folders** storages:
   - **Folder name**: `Shared Videos`
   - **External storage**: `Local`
   - **Configuration**: `/mnt/shared/Videos`
   - **Available for**: `All users`
   - **Folder name**: `Shared Photos`
   - **External storage**: `Local`
   - **Configuration**: `/mnt/shared/Photos`
   - **Available for**: `All users`
   - **Folder name**: `Shared Documents`
   - **External storage**: `Local`
   - **Configuration**: `/mnt/shared/Documents`
   - **Available for**: `All users`

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
