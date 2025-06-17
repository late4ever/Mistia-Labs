# 📋 Service Directory

> Quick lookup for all service URLs, IP addresses, ports, and access information

## 🔗 Service URLs

### 🛠️ Core Services

| Service | URL | Description | Documentation |
|---------|-----|-------------|---------------|
| **🖥️ UGREEN NASync** | [https://nexus.mistia.xyz](https://nexus.mistia.xyz) | UGREEN NASync management | _N/A_ |
| **🛡️ AdGuard Home** | [https://adguard.mistia.xyz](https://adguard.mistia.xyz) | DNS filtering and ad blocking | [View Here](../../services/adguard-home.md) |
| **⚙️ Caddy Admin API** | [https://caddy.mistia.xyz](https://caddy.mistia.xyz) | Caddy configuration management | [View Here](../../services/caddy.md#admin-api) |
| **🐳 Portainer** | [https://portainer.mistia.xyz](https://portainer.mistia.xyz) | Docker container management | [View Here](../../services/portainer.md) |
| **💾 Duplicati** | [https://duplicati.mistia.xyz](https://duplicati.mistia.xyz) | Backup management interface | [View Here](../../services/duplicati.md) |
| **📚 MkDocs** | [https://docs.mistia.xyz](https://docs.mistia.xyz) | Mistia-Nexus documentation site | [View Here](../../services/mkdocs.md) |

## 🌐 Network Configuration

### 📍 IP Address Allocation

| Service / Node | IP Address | MAC Address | Notes |
|--------------------|------------|-------------|-------|
| **🌐 Router Gateway** | `192.168.50.1` | _Router dependent_ | Network gateway |
| **🛡️ AdGuard Home** | `192.168.50.2` | _Container macvlan_ | Dedicated DNS IP |
| **🔗 Macvlan-Host** | `192.168.50.3` | _Virtual Bridge_ | Macvlan Host Bridge |
| **🖥️ UGREEN NASync Host** | `192.168.50.4` | _Hardware dependent_ | Main system IP |

### 🔌 Port Mapping

| Service | Host Port | Container Port | Protocol | Purpose |
|---------|-----------|----------------|----------|---------|
| **🖥️ UGREEN NASync** | `9999, 9443` | - | HTTP/HTTPS | NAS |
| **🛡️ AdGuard Home** | _Direct IP_ | `80, 53` | HTTP/DNS | DNS filtering |
| **🔀 Caddy** | `80, 443, 2019` | `80, 443, 443/udp, 2019` | HTTP/HTTPS | Reverse proxy & Admin API |
| **🐳 Portainer** | _Proxied_ | `8000, 9000, 9443` | HTTP | Docker management |
| **💾 Duplicati** | _Proxied_ | `8200` | HTTP | Backup interface |
| **📚 MkDocs** | _Proxied_ | `8000` | HTTP | Documentation |

## 🐳 Docker Information

### 🕸️ Container Networks

| Network | Type | Purpose |
|---------|------|---------|
| **🌐 mistia-proxy-net** | Bridge | Internal service communication |
| **🛡️ adguard-net** | Macvlan | AdGuard direct network access |

### 💾 Volume Locations

Host path starts with: `/volume2/docker/mistia-nexus/`
<!-- markdownlint-disable MD033 -->
| Service | Host Path | Container Path | Purpose |
|---------|-----------|----------------|---------|
| **🛡️ AdGuard Home** | `adguard-home/config`<br>`adguard-home/work` | `/opt/adguardhome/conf`<br>`/opt/adguardhome/work` | DNS configurations |
| **🔀 Caddy** | `caddy/data`<br>`caddy/www` | `/data`<br>`/srv/www` | Certificates and statuc files |
| **🐳 Portainer** | `portainer/data` | `/data` | Configuration storage |
| **💾 Duplicati** | `duplicati/config` | `/config` | Backup configurations |

## 🆘 Emergency Access

### 🔑 SSH Access

```bash
# Connect to NAS
ssh late4ever@192.168.50.4
# or
ssh late4ever@mistia-nexus.local
```

### 🎯 Direct Service Access (if proxy fails)

| Service | Direct URL | Use Case |
|---------|------------|----------|
| **🛡️ AdGuard Home** | [http://192.168.50.2](http://192.168.50.2) | Direct DNS management |
| **🖥️ UGREEN NASync** | [https://192.168.50.4:9443](https://192.168.50.4:9443) | System management |

### 📁 Critical File Locations

```bash
# Docker compose files
/volume2/docker/mistia-nexus/<service>/docker-compose.yml

# Environment files (secrets)
/volume2/docker/mistia-nexus/<service>/.env

# Service data (a combination of the below)
/volume2/docker/mistia-nexus/<service>/data/
/volume2/docker/mistia-nexus/<service>/config/
/volume2/docker/mistia-nexus/<service>/work/

# Backup location
/volume2/Backups/
```

## 📱 Mobile Access

### 🛡️ Tailscale VPN (when configured)

- Install Tailscale app on mobile device
- Use same URLs: `https://portainer.mistia.xyz`
- Access from anywhere securely

### 🏠 Local Network Only

- Must be connected to same WiFi network
- Use same URLs for access
- Faster speeds, local-only access
