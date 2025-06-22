---
icon: material/clipboard-text
---

# 📋 Service Directory

<!-- markdownlint-disable MD033 -->

!!! abstract "Overview"
    A quick reference for all service URLs, IP addresses, ports, and access information.

## 🔗 Service URLs

### 🕹️ Hardware Interface

| Service | URL |
|---------|-----|
| **:material-router-wireless: Router**<br>ASUS ZenWiFi Pro ET12 | [https://asus-et12.mistia.xyz](https://asus-et12.mistia.xyz)<br>[https://192.168.50.1:8443](https://192.168.50.1:8443) |
| **:material-nas: Mistia Nexus**<br>UGREEN NASync DXP4800 Plus | [https://nexus.mistia.xyz](https://nexus.mistia.xyz)<br>[https://192.168.50.4:9443](https://192.168.50.4:9443) |

### 🛠️ Core Services

| Service | URL | Purpose | Documentation |
|---------|-----|---------|---------------|
| **:simple-adguard:{ .adguard } AdGuard Home** | [https://adguard.mistia.xyz](https://adguard.mistia.xyz)<br>[https://192.168.50.2](https://192.168.50.2) | Network-wide DNS filtering | [View Here](../services/adguard-home.md) |
| **:simple-caddy:{ .caddy } Caddy**<br>:material-api: Admin API | _Infrastructure_<br>[https://caddy.mistia.xyz](https://caddy.mistia.xyz/config) | Reverse proxy with auto-HTTPS<br>Configuration management | [View Here](../services/caddy.md) |
| **:simple-tailscale: Tailscale** | [Tailscale Admin Console](https://login.tailscale.com/admin/machines) | Secure remote access VPN | [View Here](../services/tailscale.md) |
| **:simple-portainer:{ .portainer } Portainer** | [https://portainer.mistia.xyz](https://portainer.mistia.xyz) | Docker management | [View Here](../services/portainer.md) |
| **:simple-duplicati:{ .duplicati } Duplicati** | [https://duplicati.mistia.xyz](https://duplicati.mistia.xyz) | Encrypted backups | [View Here](../services/duplicati.md) |

### ☁️ Cloud Services

| Service | URL | Purpose | Documentation |
|---------|-----|---------|---------------|
| **:simple-nextcloud:{ .nextcloud } Nextcloud** | [https://nextcloud.mistia.xyz](https://nextcloud.mistia.xyz) | Self-hosted file sync and collaboration | [View Here](../services/nextcloud.md) |
| **:material-file-cloud: FileCloud** | [https://filecloud.mistia.xyz](https://filecloud.mistia.xyz) | Web-based access to SMB shares | [View Here](../services/filecloud.md) |

## 🌐 Network Configuration

### :material-ip: IP Address Allocation

| Network Node | IP Address | Description |
|--------------|:----------:|--------------------|
| **🌐 Default Gateway** | `192.168.50.1` | Main router providing internet access and local routing. |
| **:simple-adguard:{ .adguard } AdGuard Home** | `192.168.50.2` | Primary DNS sinkhole service for network-wide ad blocking. |
| **:material-lan: Macvlan-Host** | `192.168.50.3` | Dedicated interface for Host to reach Adguard Home |
| **:material-nas: UGREEN NASync Host** | `192.168.50.4` | UGREEN NASyc host system. |
| **:simple-caddy:{ .caddy } Caddy Reverse Proxy** | `192.168.50.4:443` | Manages external access to services with SSL. |
