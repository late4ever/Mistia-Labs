# 🏠 Mistia-Nexus Homelab Documentation

> The official documentation site for the Mistia-Nexus homelab.

## 🗺️ Nexus Overview

### 🕹️ Hardware

| Component | Details |
|-----------|---------|
| **NAS** | UGREEN NASync DXP4800 Plus |
| **RAM** | 2x 32GB Crucial DDR5-4800 SODIMM |
| **NVMe** | 2TB Samsung 990 Pro (Apps) |
| **HDD** | 2x 8TB WD Red Plus RAID 1 (Data) |
| **Router** | ASUS ZenWiFi Pro ET12 |
| **Switch** | TP-LINK TL-SG105-M2 5-port 2.5Gbps |

### 🌐 Network Configuration

| Network Node | IP Address | Role / Description |
|--------------|------------|--------------------|
| **🌐 Default Gateway** | `192.168.50.1` | Main router providing internet access and local routing. |
| **🛡️ AdGuard Home** | `192.168.50.2` | Primary DNS sinkhole service for network-wide ad blocking. |
| **🔗 Macvlan-Host** | `192.168.50.3` | Dedicated interface for Host to reach Adguard Home |
| **🖥️ UGREEN NASync Host** | `192.168.50.4` | UGREEN NASyc host system. |
| **🔀 Caddy Reverse Proxy** | `192.168.50.4:80/443` | Manages external access to services with SSL. |

### 🛠️ Core Services

| Service | URL | Purpose | Documentation |
|---------|-----|---------|---------------|
| **🛡️ AdGuard Home** | [https://adguard.mistia.xyz](https://adguard.mistia.xyz) | Network-wide DNS filtering | [Docs](../../services/adguard-home.md) |
| **🔀 Caddy** | _Infrastructure_ | Reverse proxy with auto-HTTPS | [Docs](../../services/caddy.md) |
| **⚙️ Caddy Admin API** | [https://caddy.mistia.xyz](https://caddy.mistia.xyz) | Caddy configuration management | [Docs](../../services/caddy.md#admin-api) |
| **🐳 Portainer** | [https://portainer.mistia.xyz](https://portainer.mistia.xyz) | Docker management | [Docs](../../services/portainer.md) |
| **💾 Duplicati** | [https://duplicati.mistia.xyz](https://duplicati.mistia.xyz) | Encrypted backups | [Docs](../../services/duplicati.md) |
| **📚 MkDocs** | [https://docs.mistia.xyz](https://docs.mistia.xyz) | This documentation | [Docs](../../services/mkdocs.md) |
