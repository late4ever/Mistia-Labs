---
icon: simple/adguard
---

# :simple-adguard:{ .adguard } AdGuard Home

<!-- markdownlint-disable MD033 -->

!!! abstract "Overview"
    AdGuard Home is a powerful, network-wide ad and tracker blocking DNS server that acts as a centralized shield for your entire network, removing ads, trackers, and malicious domains from all your devices. By routing your network's DNS traffic through AdGuard Home, you gain granular control over what content is accessed, significantly enhancing your privacy and browsing experience.

## 📑 Service Information

:material-web: [https://adguard.mistia.xyz](https://adguard.mistia.xyz) &nbsp;&nbsp;&nbsp; :material-ip: [http://192.168.50.2](http://192.168.50.2)

:fontawesome-regular-id-badge: adguard-home &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: adguard/adguardhome:latest

| Host Ports | Container Ports | Network |  Host Path | Container Path |
|:----------:|:------------:|:----------:|:----------:|:--------------:|
| Direct IP | `53/tcp, 53/udp, 80` | `adguard-net` | `adguard-home/confdir`<br>`adguard-home/workdir` | `/opt/adguardhome/conf`<br>`/opt/adguardhome/work` |

## 📋 Prerequisites

### 🌐 Network Requirements

- **Dedicated IP**: `192.168.50.2`
- **Network Interface**: Create a virtual bridge on UGREEN NASync to be used for AdGuard Home container's Macvlan network

## 🔧 Configuration

### 📂 Host Directory

```text
mistia-nexus/
└── adguard-home/          
    ├── .critical             # Prevents this service from being managed by start/stop scripts
    ├── docker-compose.yml    # Defines the AdGuard Home service, network, and volumes
    ├── confdir/              # Mapped volume
    └── workdir/              # Mapped volume
```

### 📁 Container Directory

```text
/opt/adguardhome/
├── conf/                  # Stores the main AdGuard Home configuration
│   └── AdGuardHome.yaml   # The primary YAML configuration file for the service
└── work/                  # Contains dynamic data, logs, and filters
    └── data/              
        ├── filters/       # Caches the filter lists used for blocking
        ├── stats.db       # Holds the statistical data for the dashboard
        └── sessions.db    # Manages user session information
```

### 🐋 Docker Compose

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/adguard-home/docker-compose.yml"
```

### Reverse Proxy

```Caddyfile title="Caddyfile"
--8<-- "mistia-nexus/caddy/Caddyfile:adguard"
```

### 📄 Application Secret

```text
not needed
```

## ✨ Initial Deployment

```bash
cd /volume2/docker/mistia-nexus/
./script/update.sh adguard-home
```

## ⚙️ Post-Deployment

### 🌉 Host Network Bridge

Follow the instructions at [Configure DNS Sinkhole](../../initial-setup/mistia-nexus#configure-dns-sinkhole) to setup the startup service in UGREEN NASync

!!! danger "Required Setup"
    AdGuard uses macvlan networking, which requires a virtual interface on the host to enable communication between the NAS and the container.
    This configuration resets on UGREEN NAS reboot.

```bash title="mistia-nexus-macvlan-host.sh"
--8<-- "bootstrap/mistia-nexus-macvlan-host.sh"
```

!!! note "Virtual Bridge Automation"
    The host network bridge required for the host to communicate with the macvlan container will be managed automatically by a systemd service.

```systemd title="mistia-nexus-macvlan-host.service"
--8<-- "bootstrap/mistia-nexus-macvlan-host.service"
```

## 🚀 Initial Setup

1. Navigate to [http://192.168.50.2:3000](http://192.168.50.2:3000)

2. Complete the setup wizard

      - Step 1: Click "Get Started"
      - Step 2 (Web Interface): Leave the listen interface as "All interfaces" and the port as 80
      - Step 3 (DNS Server): Leave the listen interface as "All interfaces" and the port as 53
      - Step 4 (Authentication): Create a strong username and password for your AdGuard Home admin panel. Save these in your password manager
      - Step 5 (Done): Finish the setup. You will be automatically redirected to your new dashboard

3. Follow the instructions in this [Github Repo](https://github.com/celenityy/adguard-home-settings/blob/main/README.md) to configure the rest of the settings

4. Navigate to `Filters` >> `DNS rewrites`

5. Create a new entry for **Domain**: `*.mistia.xyz` **Answer**: `192.168.50.4`
