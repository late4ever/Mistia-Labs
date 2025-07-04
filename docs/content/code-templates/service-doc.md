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

| Container<br>`Only for`<br>`multiple services` | Host Ports | Container Ports | Network |  Host Path | Container Path |
|:--------- |:----------:|:------------:|:----------:|:----------:|:--------------:|
| `Only for multi` | `[host-port]` | `[container-ports]` | `[network]` | `[host volume]` | `[container path]` |

## 📋 Prerequisites

[Add any prerequisites here.]

### 🗂️ NVMe Storage

SSH into the NAS to create the NVMe volume

```bash
--8<-- "docs/content/.snippets/ssh.sh:ssh"
```

Create the required folders

```bash
sudo mkdir -p /volume1/docker/[service-name]/[folder-name]
```

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
# sample only
--8<-- "docs/content/.snippets/docker-compose.yml"
```

### 🐋 Dockerfile

```yaml title="Dockerfile"
--8<-- "[service-name]/Dockerfile"
```

### 🔀 Reverse Proxy

```Caddyfile title="Caddyfile"
--8<-- "caddy/Caddyfile:[service-name]"
# sample only
--8<-- "docs/content/.snippets/Caddyfile"
```

### :simple-ansible: Ansible

--8<-- "docs/content/.snippets/ansible.sh:ve"

#### Ansible Vault

```bash
--8<-- "docs/content/.snippets/ansible.sh:vault-edit"
```

Press ++i++ to enter `Insert Mode`

```yaml title="secrets.yml"
the-key-name: "the-key-value"
```

Press ++esc++ to exit `Insert Mode`

Type ++colon++ ++w++ ++q++ and press ++enter++ to save and exit

#### Secrets Template

```bash
nano ansible/mistia-nexus/secrets.template.yml
```

```yaml title="secrets.template.yml"
the-key-name: ""
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

#### .env Template

```bash
touch ansible/mistia-nexus/templates/[service-name].env.j2
nano ansible/mistia-nexus/template/[service-name].env.j2
```

```j2 title="[service-name].env.j2"
THE_KEY_NAME= {{ the-key-name }}
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

#### Deploy-Services Playbook

```bash
nano ansible/mistia-nexus/deploy-services.yml
```

```yaml title="deploy-services.yml"
--8<-- "ansible/mistia-nexus/deploy-services.yml:service-name"
# sample only
--8<-- "docs/content/.snippets/deploy-services.yml"
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

#### DNS Rewrite Entry

```bash
nano ansible/group_vars/all/dns.yml
```

```yaml title="dns.yml"
--8<-- "ansible/group_vars/all/dns.yml:[service-name]"
# sample only
--8<-- "docs/content/.snippets/dns.yml"
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

## ✨ Deployment

--8<-- "docs/content/.snippets/ansible.sh:ve"

```bash
# sample only
--8<-- "docs/content/.snippets/ansible.sh:playbook"
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
