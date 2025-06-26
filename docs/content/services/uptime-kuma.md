---
icon: material/teddy-bear
---

# 🐻 Uptime Kuma

<!-- markdownlint-disable MD033 -->

!!! abstract "Overview"
    Uptime Kuma is a fancy, easy-to-use, self-hosted monitoring tool. It allows you to monitor the uptime for your HTTP(s)/TCP/Ping services and receive notifications, providing a clear dashboard of your homelab's health.

## 📑 Service Information

:material-web: [https://kuma.mistia.xyz](https://kuma.mistia.xyz) &nbsp;&nbsp;&nbsp; :material-nas: [http://mistia-nexus.local:10004](http://mistia-nexus.local:10004)

:fontawesome-regular-id-badge: kuma &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: louislam/uptime-kuma:1

| Host Ports | Container Ports | Network |  Host Path | Container Path |
|:----------:|:------------:|:----------:|:----------:|:--------------:|
| `10004` | `3001` | `mistia-proxy-net` | `uptime-kuma/data` | `/app/data` |

## 📋 Prerequisites

### 🌐 Network Requirements

The `mistia-proxy-net` network must be available.

## 🔧 Configuration

### 📂 Host Directory

```text
mistia-nexus/
└── uptime-kuma/
    ├── docker-compose.yml  # Defines the Uptime Kuma service, network, and volumes
    └── data/               # Mapped volume for persistent data
```

### 📁 Container Directory

```text
/app/data     # Uptime Kuma's persistent data (database, settings)
```

### 🐋 Docker Compose

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/uptime-kuma/docker-compose.yml"
```

### 🔀 Reverse Proxy

```Caddyfile title="Caddyfile"
--8<-- "mistia-nexus/caddy/Caddyfile:kuma"
```

### :simple-ansible: Ansible

#### Ansible Vault

--8<-- "docs/content/.snippets/general.txt:na"

#### Secrets Template

--8<-- "docs/content/.snippets/general.txt:na"

#### .env Template

--8<-- "docs/content/.snippets/general.txt:na"

#### Deploy-Services Playbook

```bash
nano ansible/mistia-nexus/deploy-services.yml
```

```yaml title="deploy-services.yml"
--8<-- "ansible/mistia-nexus/deploy-services.yml:kuma"
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

#### DNS Rewrite Entry

```bash
nano ansible/group_vars/all/dns.yml
```

```yaml title="dns.yml"
--8<-- "ansible/group_vars/all/dns.yml:kuma"
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

## ✨ Deployment

```bash
nexus-deploy --tags proxy-reload,uptime-kuma
```

## 🚀 Initial Setup

### 🪪 Account Setup

1. Navigate to [https://kuma.mistia.xyz](https://kuma.mistia.xyz)

2. Create an administrator account

3. Start adding your services as monitors. A good starting point is to add all the `*.mistia.xyz` URLs for your core services
