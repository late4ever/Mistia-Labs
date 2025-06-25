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
| Direct IP | `53/tcp, 53/udp, 80`<br>`443/tcp, 443/udp`<br>`853/tcp, 853/udp` | `adguard-net` | `adguard-home/confdir`<br>`adguard-home/workdir`<br>`caddy/data` | `/opt/adguardhome/conf`<br>`/opt/adguardhome/work`<br>`/opt/adguardhome/certs:ro` |

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

### 🔀 Reverse Proxy

```Caddyfile title="Caddyfile"
--8<-- "mistia-nexus/caddy/Caddyfile:adguard"
```

### :simple-ansible: Ansible

#### Ansible Virtual Environment

Open the repo in WSL terminal

```bash
--8<-- "docs/content/.snippets/ansible.sh:ve"
```

#### Ansible Vault

--8<-- "docs/content/.snippets/general.txt:na"

#### .env Template

--8<-- "docs/content/.snippets/general.txt:na"

#### Deploy-Services Playbook

Define the service

```yaml title="deploy-services.yml"
--8<-- "ansible/mistia-nexus/deploy-services.yml:adguard-home"
```

## ✨ Deployment

--8<-- "docs/content/.snippets/ansible.sh:ve"

```bash
ansible-playbook deploy-services.yml --tags dns
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

### 🪪 Account Setup

1. Navigate to [http://192.168.50.2:3000](http://192.168.50.2:3000)

2. Complete the setup wizard

      - Click **Get Started**
      - **Web Interface:**
        - Leave the listen interface as `All interfaces` and the port as `80`
      - **DNS Server:**
        - Leave the listen interface as `All interfaces` and the port as `53`
      - **Authentication:**
        - Create username and password for your AdGuard Home admin panel
      - **Done:** Finish the setup

### ⚙️ Configure AdGuard Settings

Follow the instructions in this [Github Repo](https://github.com/celenityy/adguard-home-settings/blob/main/README.md) to configure the rest of the settings

#### Encryption Settings

1. Navigate to [AdGuard Home >> Settings >> Encryption settings](https://adguard.mistia.xyz/#encryption)

2. Check **Enable Encryption (HTTPS, DNS-over-HTTPS, and DNS-over-TLS)**

3. **Server name:** `adguard.mistia.xyz`

4. Do not check **Redirect to HTTPS automatically**

5. **Certificates:**
   - Select **Set a certificates files path**
   - Enter: `/opt/adguardhome/certs/caddy/certificates/acme-v02.api.letsencrypt.org-directory/adguard.mistia.xyz/adguard.mistia.xyz.crt`

6. **Private key**
   - Select **Set a private key file**
   - Enter: `/opt/adguardhome/certs/caddy/certificates/acme-v02.api.letsencrypt.org-directory/adguard.mistia.xyz/adguard.mistia.xyz.key`

7. Click `Save configuration`

To use DoH: [https://adguard.mistia.xyz/dns-query](https://adguard.mistia.xyz/dns-query)
To use Dot: [tls://adguard.mistia.xyz/dns-query](tls://adguard.mistia.xyz)

### 📝 DNS Rewrite

1. Navigate to [http://192.168.50.2](http://192.168.50.2) >> `Filters` >> `DNS rewrites`

2. Click `Add DNS rewrite`
      - **Domain**: `adguard.mistia.xyz`
      - **Answer**: `192.168.50.4`
      - Click `Save`

3. Logout and navigate to [https://adguard.mistia.xyz](https://adguard.mistia.xyz) to verify
