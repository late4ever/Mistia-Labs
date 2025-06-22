---
icon: simple/caddy
status: new
---

# :simple-caddy:{ .caddy } Caddy

<!-- markdownlint-disable MD033 -->

!!! abstract "Overview"
    Caddy is an automatic HTTPS reverse proxy that handles all external traffic, provides valid certificates, and routes requests to the appropriate internal services. It uses the Cloudflare DNS plugin to complete challenges, ensuring secure and encrypted connections for the homelab.

## 📑 Service Information

:material-web: [https://caddy.mistia.xyz]("https://caddy.mistia.xyz") (Caddy Admin API)

:fontawesome-regular-id-badge: caddy &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: caddy:latest

| Host Ports | Container Ports | Network | Host Path | Container Path |
|:----------:|:---------------:|:-------:|:---------:|:--------------:|
| `80, 443, 853` | `80, 443/tcp, 443/udp, 853` | `mistia-proxy-net` | `caddy/Caddyfile`<br>`caddy/config`<br>`caddy/data`<br>`caddy/www` | `/etc/caddy/Caddyfile`<br>`/config`<br>`/data`<br>`/srv/www` |

## 📋 Prerequisites

- **Internal DNS rewrite**: AdGuard Home configured to resolve `*.mistia.xyz` to `192.168.50.4`
- **Cloudflare API Token**: For automatic HTTPS certificate issuance using Let's Encrypt via the DNS-01 challenge.

!!! note "mistia-proxy-net"
    The `mistia-proxy-net` network will be created by this container

## 🔧 Configuration

### 📂 Host Directory

```text
mistia-nexus/
└── caddy/
    ├── .env                # Application secrets
    ├── docker-compose.yml  # Defines the Caddy service, build, network, and volumes
    ├── Dockerfile          # Builds the Caddy image with the required plugins
    ├── Caddyfile           # The main configuration file for reverse proxy routing
    ├── data/               # Mapped volume
    ├── www/                # Mapped volume for static files
    ├── db_data/            # Stores internal database files used by Caddy
    └── letsencrypt/        # Contains SSL/TLS certificates issued by Let's Encrypt
```

### 📁 Container Directory

```text
/
├── etc/caddy/
│   └── Caddyfile   # The loaded Caddy configuration file
├── data/           # Stores certificates and other persistent Caddy data
└── srv/www/        # Serves static files 
```

### 🐋 Docker Compose

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/caddy/docker-compose.yml"
```

### 🐋 Dockerfile

```yaml title="Dockerfile"
--8<-- "mistia-nexus/caddy/Dockerfile"
```

### 🔀 Caddyfile

```Caddyfile title="Caddyfile"
--8<-- "mistia-nexus/caddy/Caddyfile"
```

### 🔀 Custom 404

```html title="404.html"
--8<-- "mistia-nexus/caddy/www/404.html"
```

### 📄 Application Secret

Create this `.env` file in the deployment location.

```bash
cd /volume2/docker/mistia-nexus/
./script/git-update.sh

cd /volume2/docker/mistia-nexus/caddy
sudo nano .env
```

```text title=".env"
CLOUDFLARE_API_TOKEN=[secret-here]
CADDY_EMAIL=late4ever+caddy@gmail.com
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

```bash
chmod 600 .env
```

## ✨ Initial Deployment

```bash
cd /volume2/docker/mistia-nexus/
./script/update.sh caddy
```

## 🚀 Initial Setup

### 📝 DNS Rewrite

1. Navigate to [https://adguard.mistia.xyz](https://adguard.mistia.xyz) >> `Filters` >> `DNS rewrites`

2. Click `Add DNS rewrite`
      - **Domain**: `caddy.mistia.xyz`
      - **Answer**: `192.168.50.4`
      - Click `Save`

3. Navigate to [https://caddy.mistia.xyz](https://caddy.mistia.xyz) to verify
