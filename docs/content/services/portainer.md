---
icon: simple/portainer
---

# :simple-portainer:{ .portainer } Portainer

<!-- markdownlint-disable MD033 -->

!!! abstract "Overview"
    Portainer is a lightweight management UI that allows you to easily manage your Docker environments by providing a detailed overview of your containers, images, networks, and volumes. This service simplifies the complexity of the command line, making it an essential tool for both beginners and experienced users to visualize and manage their containerized applications.

## 📑 Service Information

:material-web: [https://portainer.mistia.xyz](https://portainer.mistia.xyz)  &nbsp;&nbsp;&nbsp; :material-nas: [https://mistia-nexus.local:10001](https://mistia-nexus.local:10001)

:fontawesome-regular-id-badge: portainer &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: portainer/portainer-ce:alpine

| Host Ports | Container Ports | Network |  Host Path | Container Path |
|:----------:|:------------:|:----------:|:----------:|:--------------:|
| `10001` | `8000`,`9000`,`9443` | `mistia-proxy-net` | `portainer/data`<br>`/var/run/docker.sock` | `/data`<br>`/var/run/docker.sock` |

## 📋 Prerequisites

### 🌐 Network Requirements

The `mistia-proxy-net` network must be available.

## 🔧 Configuration

### 📂 Host Directory

```text
mistia-nexus/
└── portainer/
    ├── docker-compose.yml  # Defines the Portainer service, network, and volumes
    └── data/               # Mapped volume
```

### 📁 Container Directory

```text
/
├── data/                   # Portainer's persistent data
└── var/run/docker.sock     # Docker socket for container management
```

### 🐋 Docker Compose

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/portainer/docker-compose.yml"
```

### 🔀 Reverse Proxy

```Caddyfile title="Caddyfile"
--8<-- "mistia-nexus/caddy/Caddyfile:portainer"
```

### :simple-ansible: Ansible

#### Ansible Vault

--8<-- "docs/content/.snippets/general.txt:na"

#### .env Template

--8<-- "docs/content/.snippets/general.txt:na"

#### Deploy-Services Playbook

Define the service

```yaml title="deploy-services.yml"
--8<-- "ansible/mistia-nexus/deploy-services.yml:portainer"
```

## ✨ Deployment

--8<-- "docs/content/.snippets/ansible.sh:ve"

```bash
nexus-deploy --tags proxy-reload,portainer
```

## ⚙️ Post-Deployment

### 📝 DNS Rewrite

1. Navigate to [https://adguard.mistia.xyz](https://adguard.mistia.xyz) >> `Filters` >> `DNS rewrites`

2. Click `Add DNS rewrite`
      - **Domain**: `portainer.mistia.xyz`
      - **Answer**: `192.168.50.4`
      - Click `Save`

3. Navigate to [https://portainer.mistia.xyz](https://portainer.mistia.xyz) to verify

## 🚀 Initial Setup

### 🪪 Account Setup

1. Navigate to [https://portainer.mistia.xyz](https://portainer.mistia.xyz)

2. Create an administrator account

3. Select the `Local` environment and click `Connect` to manage the local Docker instance
