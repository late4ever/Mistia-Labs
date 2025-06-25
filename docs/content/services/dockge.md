---
icon: material/egg-fried
---

# :material-egg-fried: Dockge

!!! abstract "Overview"
    Dockge is a fancy, easy-to-use, and reactive self-hosted docker compose.yaml stack-oriented manager. It allows you to manage your docker-compose files through a user-friendly web interface.

## 📑 Service Information

:material-web: [https://dockge.mistia.xyz](https://dockge.mistia.xyz) &nbsp;&nbsp;&nbsp; :material-nas: [http://mistia-nexus.local:10002](http://mistia-nexus.local:10002)

:fontawesome-regular-id-badge: dockge &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: louislam/dockge:latest

| Host Ports | Container Ports | Network |  Host Path | Container Path |
|:----------:|:------------:|:----------:|:----------:|:--------------:|
| `10002` | `5001` | `mistia-proxy-net` | `./data`<br>`..` | `/app/data`<br>`/stacks` |

## 📋 Prerequisites

### 🌐 Network Requirements

The `mistia-proxy-net` network must be available.

## 🔧 Configuration

### 📂 Host Directory

```text
mistia-nexus/               # Mapped to /stacks for managing compose files
└── dockge/
    ├── docker-compose.yml  # Defines the Dockge service, network, and volumes
    └── data/               # Mapped volume for persistent data
```

### 📁 Container Directory

```text
/app/data     # Dockge's persistent data
/stacks       # Location of docker-compose stacks
```

### 🐋 Docker Compose

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/dockge/docker-compose.yml"
```

### 🔀 Reverse Proxy

```Caddyfile title="Caddyfile"
--8<-- "mistia-nexus/caddy/Caddyfile:dockge"
```

### :simple-ansible: Ansible

#### Ansible Vault

--8<-- "docs/content/.snippets/general.txt:na"

#### .env Template

--8<-- "docs/content/.snippets/general.txt:na"

#### Deploy-Services Playbook

Define the service

```yaml title="deploy-services.yml"
--8<-- "ansible/mistia-nexus/deploy-services.yml:dockge"
```

## ✨ Deployment

```bash
nexus-deploy --tags proxy-reload,dockge
```

## ⚙️ Post-Deployment

### 📝 DNS Rewrite

1. Navigate to [https://adguard.mistia.xyz](https://adguard.mistia.xyz) >> `Filters` >> `DNS rewrites`

2. Click `Add DNS rewrite`
      - **Domain**: `dockge.mistia.xyz`
      - **Answer**: `192.168.50.4`
      - Click `Save`

3. Navigate to [https://dockge.mistia.xyz](https://dockge.mistia.xyz) to verify

## 🚀 Initial Setup

### 🪪 Account Setup

1. Navigate to [https://dockge.mistia.xyz](https://dockge.mistia.xyz)

2. Create an administrator account
