---
icon: simple/tailscale
---

# :simple-tailscale: Tailscale

<!-- markdownlint-disable MD033 -->

!!! abstract "Overview"
    Tailscale is a zero-config VPN that creates a secure, private network between your devices, no matter where they are. It enables remote access to your entire homelab, including LAN devices, and funnels traffic through your home's ad-blocking DNS, all without opening any firewall ports.

## 📑 Service Information

:material-web: [https://login.tailscale.com/admin/machines](https://login.tailscale.com/admin/machines)

:fontawesome-regular-id-badge: tailscale &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: tailscale/tailscale:latest

| Host Ports | Container Ports | Network | Host Path | Container Path |
|:----------:|:---------------:|:-------:|:---------:|:--------------:|
| *host mode* | *host mode* | `host` | `tailscale/state`<br>`/dev/net/tun` | `/var/lib/tailscale`<br>`/dev/net/tun` |

## 📋 Prerequisites

1. Create a [Tailscale account](https://login.tailscale.com/login)  

2. Navigate to the [Tailscale Admin Console >> Settings >> Keys](https://login.tailscale.com/admin/settings/keys)

3. Click `Generate auth key...`
   - Configure the key:
   - **Description:** `Mistia-Nexus`
   - **Reusable:** `Enabled`
   - **Ephemeral:** `Enabled`
   - **Tags:** `tags:nas-router`

4. Click `Generate key`

5. Copy the key

!!! note "Host Networking"
    This service uses `network_mode: host`, which gives it direct access to the NAS's networking stack. This is required for its function as a subnet router and exit node. It does not use the `mistia-proxy-net`.

## 🔧 Configuration

### 📂 Host Directory

```text
mistia-nexus/
└── tailscale/
    ├── .env                # Application secrets (stores the auth key)
    ├── docker-compose.yml  # Defines the Tailscale service
    └── state/              # Mapped volume
```

### 📁 Container Directory

```text
/
├── var/lib/tailscale/  # Stores the persistent state and identity of the Tailscale node
└── dev/net/tun         # Allows the container to create a VPN network interface
```

### 🐋 Docker Compose

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/tailscale/docker-compose.yml"
```

### 🔀 Reverse Proxy

```text
not needed
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
ts_authkey: "tailscale-auth-key"
```

Press ++esc++ to exit `Insert Mode`
Type ++colon++ ++w++ ++q++ and press ++enter++ to save and exit

#### .env Template

```bash
touch templates/tailscale.env.j2
nano template/tailscale.env.j2
```

```j2 title="tailscale.env.j2"
TS_AUTHKEY={{ "tailscale-auth-key" }}
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

#### Deploy-Services Playbook

Define the service

```yaml title="deploy-services.yml"
--8<-- "ansible/mistia-nexus/deploy-services.yml:tailscale"
```

## ✨ Deployment

--8<-- "docs/content/.snippets/ansible.sh:ve"

```bash
ansible-playbook deploy-services.yml --tags tailscale
```

## 🚀 Initial Setup

### ⚙️ Authorize Node and Routes

1. Navigate to [Tailscale Admin Console >> Machines](https://login.tailscale.com/admin/machines)

2. You will see your new `mistia-nexus` node.

3. Click the **three-dot** menu `...` next to the machine and select `Edit route settings...`
    - Approve the advertised features:
        - Check **192.168.50.0/24**
        - Check **Use as exit node**
    - Click `Save`

### 🔗 Configure Global DNS

To enable network-wide ad-blocking for all your remote devices, configure your tailnet to use your AdGuard Home instance.

1. Navigate to [Tailscale Admin Console >> DNS](https://login.tailscale.com/admin/dns)

2. Under the `Nameservers` section, click `Add nameserver` and select `Custom`

3. Enter the local IP address of your AdGuard Home container: **192.168.50.2**

4. Click `Save`

5. Toggle on **Override local DNS**. This ensures your remote devices use your AdGuard Home for DNS queries instead of whatever network they are connected to

### 📱 Connect Client Devices

On your phone, laptop, or other remote devices:

1. Install the Tailscale client and log in.
2. In the client settings, select **Exit Node...**.
3. Choose `mistia-nexus-tailscale` from the list.

Your device will now route all its internet traffic through your home network, gaining the full benefits of your AdGuard Home setup, and will be able to access all local devices (like Sonos) as if it were right at home.
