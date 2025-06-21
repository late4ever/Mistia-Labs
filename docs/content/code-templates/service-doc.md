---
icon: material/application-brackets
---

# :material-application-brackets: [Service Name]

<!-- markdownlint-disable MD033 -->

!!! abstract "Overview"
    A brief, two-sentence description of the service and its purpose within the homelab.

## 📑 Service Information

:material-web: [service-url]

:fontawesome-regular-id-badge: [container-name] &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: [image-name]

| Host Ports | Container Ports | Network |  Host Path | Container Path |
|:----------:|:------------:|:----------:|:----------:|:--------------:|
| `[host-port]` | `[container-ports]` | `[network]` | `[host volume]` | `[container path]` |

## 📋 Prerequisites

[Add any prerequisites here.]

## 🔧 Configuration

### 📂 Host Directory

```text
mistia-nexus/
└── [service-name]/
    ├── .env
    ├── docker-compose.yml
    └── [other_files]/
```

### 📁 Container Directory

```text
/path/to/container/data/
├── config/
└── data/
```

### 🐋 Docker Compose

Retrieve the PUID and PGID values for the `docker-compose.yml`

```bash
--8<-- "docs/content/.snippets/ssh.sh:sshid"
```

```yaml title="docker-compose.yml"
--8<-- "[service-name]/docker-compose.yml"
```

### 🐋 Dockerfile

```yaml title="Dockerfile"
--8<-- "[service-name]/Dockerfile"
```

### 🔀 Reverse Proxy

```Caddyfile title="Caddyfile"
--8<-- "caddy/Caddyfile:[service-name]"
```

### 📄 Application Secret

Create this `.env` file in the deployment location.

```bash
cd /volume2/docker/mistia-nexus/
./script/git-update.sh

cd /volume2/docker/mistia-nexus/[service-name]
sudo nano .env
```

```text title=".env"
[key]=[secret]
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

```bash
chmod 600 .env
```

## ✨ Initial Deployment

```bash
cd /volume2/docker/mistia-nexus/
./script/add-service.sh [service-name]
```

## ⚙️ Post-Deployment

[Describe any necessary steps to take after the container is running, such as running setup scripts, configuring reverse proxies, etc.]

## 🚀 Initial Setup

### 🪪 Account Setup

1. [Step-by-step instructions for the initial configuration of the service through its web UI or command line.]
2. [Another step.]
3. [And so on.]

### ⚙️ [Other Setup Requirements]

1. [Step-by-step instructions for the requirements]
2. [Another step.]
3. [And so on.]

### 📝 DNS Rewrite

1. Navigate to [https://adguard.mistia.xyz](https://adguard.mistia.xyz) >> `Filters` >> `DNS rewrites`

2. Click `Add DNS rewrite`
      - **Domain**: `service.mistia.xyz`
      - **Answer**: `192.168.50.4`
      - Click `Save`

3. Navigate to [https://service.mistia.xyz](https://service.mistia.xyz) to verify
