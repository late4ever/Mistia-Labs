---
icon: simple/android
---

# 🐝 Dozzle

!!! abstract "Overview"
    Dozzle is a lightweight, real-time log viewer for Docker containers. It provides a simple, web-based interface to monitor container logs without needing to access the terminal, making it easy to troubleshoot and keep an eye on your applications.

## 📑 Service Information

:material-web: [https://dozzle.mistia.xyz](https://dozzle.mistia.xyz) &nbsp;&nbsp;&nbsp; :material-nas: [http://mistia-nexus.local:10003](http://mistia-nexus.local:10003)

:fontawesome-regular-id-badge: dozzle &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: amir20/dozzle:latest

| Host Ports | Container Ports | Network |  Host Path | Container Path |
|:----------:|:------------:|:----------:|:----------:|:--------------:|
| `10003` | `8080` | `mistia-proxy-net` | `/var/run/docker.sock` | `/var/run/docker.sock:ro` |

## 📋 Prerequisites

### 🌐 Network Requirements

The `mistia-proxy-net` network must be available.

## 🔧 Configuration

### 📂 Host Directory

```text
mistia-nexus/
└── dozzle/
    └── docker-compose.yml  # Defines the Dozzle service, network, and volumes
```

### 📁 Container Directory

```text
/var/run/docker.sock     # Docker socket for container management
```

### 🐋 Docker Compose

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/dozzle/docker-compose.yml"
```

### 🔀 Reverse Proxy

```Caddyfile title="Caddyfile"
--8<-- "mistia-nexus/caddy/Caddyfile:dozzle"
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
--8<-- "ansible/mistia-nexus/deploy-services.yml:dozzle"
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

#### DNS Rewrite Entry

```bash
nano ansible/group_vars/all/dns.yml
```

```yaml title="dns.yml"
--8<-- "ansible/group_vars/all/dns.yml:dozzle"
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

## ✨ Deployment

```bash
nexus-deploy --tags proxy-reload,dozzle
```
