---
icon: simple/duplicati
---

# :simple-duplicati:{ .duplicati } Duplicati

<!-- markdownlint-disable MD033 -->

!!! abstract "Overview"
    Duplicati is a free, open-source backup client that securely stores encrypted, incremental, and compressed backups on various cloud storage services and remote file servers. With features like scheduling, backup verification, and a web-based interface, Duplicati offers a robust solution for protecting the homelab's critical data.

## 📑 Service Information

:material-web: [https://duplicati.mistia.xyz](https://duplicati.mistia.xyz)  &nbsp;&nbsp;&nbsp; :material-nas: [https://mistia-nexus.local:10101](https://mistia-nexus.local:10101)

:fontawesome-regular-id-badge: duplicati &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: lscr.io/linuxserver/duplicati:latest

| Host Ports | Container Ports | Network | Host Path | Container Path |
|:----------:|:---------------:|:----------------:|:---------------------------:|:--------------:|
| `10011` | `8200` | `mistia-proxy-net` | `duplicati/config`<br>`/` | `/config`<br>`/nasroot:ro` |

## 📋 Prerequisites

- The `mistia-proxy-net` network must be available.

## 🔧 Configuration

### 📂 Host Directory

```text
mistia-nexus/
└── duplicati/
    ├── .env                # Application secrets
    ├── docker-compose.yml  # Defines the Duplicati service, network, and volumes
    └── config/             # Mapped volume
```

### 📁 Container Directory

```text
/
├── config/   # Stores Duplicati's configuration files and local databases
└── nasroot/  # Read-only mount of the host's entire filesystem for backup source
```

### 🐋 Docker Compose

Retrieve the PUID and PGID values for the `docker-compose.yml`

```bash
--8<-- "docs/content/.snippets/ssh.sh:sshid"
```

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/duplicati/docker-compose.yml"
```

### 🔀 Reverse Proxy

```Caddyfile title="Caddyfile"
--8<-- "mistia-nexus/caddy/Caddyfile:duplicati"
```

### :simple-ansible: Ansible

#### Ansible Virtual Environment

--8<-- "docs/content/.snippets/ansible.sh:ve"

#### Ansible Vault

```bash
--8<-- "docs/content/.snippets/ansible.sh:vault-edit"
```

Press ++i++ to enter `Insert Mode`

```yaml title="secrets.yml"
duplicati_settings_key: "duplicati-settings-key"
duplicati_ui_password: "duplicati-ui-password"
```

Press ++esc++ to exit `Insert Mode`
Type ++colon++ ++w++ ++q++ and press ++enter++ to save and exit

#### .env Template

```bash
touch templates/duplicati.env.j2
nano template/duplicati.env.j2
```

```j2 title="duplicati.env.j2"
DUPLICATI_SETTINGS_KEY={{ duplicati_settings_key }}
DUPLICATI_UI_PASSWORD={{ duplicati_ui_password }}
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

#### Deploy-Services Playbook

Define the service

```yaml title="deploy-services.yml"
--8<-- "ansible/mistia-nexus/deploy-services.yml:duplicati"
```

## ✨ Deployment

--8<-- "docs/content/.snippets/ansible.sh:ve"

```bash
ansible-playbook deploy-services.yml --tags proxy-reload,duplicati
```

## ⚙️ Post-Deployment

### 📝 DNS Rewrite

1. Navigate to [https://adguard.mistia.xyz](https://adguard.mistia.xyz) >> `Filters` >> `DNS rewrites`

2. Click `Add DNS rewrite`
      - **Domain**: `duplicati.mistia.xyz`
      - **Answer**: `192.168.50.4`
      - Click `Save`

3. Navigate to [https://duplicati.mistia.xyz](https://duplicati.mistia.xyz) to verify
