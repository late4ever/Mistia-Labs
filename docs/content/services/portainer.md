---
icon: simple/portainer
---

# :simple-portainer:{ .portainer } Portainer

!!! abstract "Overview"
    Portainer is a lightweight management UI that allows you to easily manage your Docker environments by providing a detailed overview of your containers, images, networks, and volumes. This service simplifies the complexity of the command line, making it an essential tool for both beginners and experienced users to visualize and manage their containerized applications.

## 📑 Service Information

:material-web: [https://portainer.mistia.xyz](https://portainer.mistia.xyz)

:fontawesome-regular-id-badge: portainer &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: portainer/portainer-ce:alpine

<!-- markdownlint-disable MD033 -->
| Host Ports | Container Ports | Network |  Host Path | Container Path |
|:----------:|:------------:|:----------:|:----------:|:--------------:|
| *proxied* | `8000`,`9000`,`9443` | `mistia-proxy-net` | `portainer/data`<br>`/var/run/docker.sock` | `/data`<br>`/var/run/docker.sock` |

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

### Reverse Proxy

```Caddyfile title="Caddyfile"
--8<-- "mistia-nexus/caddy/Caddyfile:portainer"
```

## 📄 Application Secret

```text
not needed
```

## ✨ Initial Deployment

```bash
cd /volume2/docker/mistia-nexus/
./script/add_service.sh [service-name]
```

## 🚀 Initial Setup

1. Navigate to [https://portainer.mistia.xyz](https://portainer.mistia.xyz)

2. Create an administrator account

3. Select the "Local" environment and click "Connect" to manage the local Docker instance
