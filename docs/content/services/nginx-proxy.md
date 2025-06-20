--- 
icon: simple/nginxproxymanager
status: deprecated
---

# :simple-nginxproxymanager:{ .nginx } Nginx Proxy Manager

<!-- markdownlint-disable MD033 -->

!!! warning "Deprecated"
    This service has been deprecated. Please refer to the documentation for the new [reverse proxy server](../services/caddy.md).

!!! abstract "Overview"
    Nginx Proxy Manager is a reverse proxy management system that provides an easy-to-use web interface for creating and managing Nginx proxy hosts, including free SSL certificate generation and renewal.

## 📑 Service Information

:material-web: [https://nginx.mistia.xyz](https://nginx.mistia.xyz) &nbsp;&nbsp;&nbsp; :material-ip: [http://192.168.50.4:81](http://192.168.50.4:81)

:fontawesome-regular-id-badge: nginx-proxy &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: jc21/nginx-proxy-manager:latest

:fontawesome-regular-id-badge: nginx-proxy-db &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: jc21/mariadb-aria:latest

| Host Ports | Container Ports | Network | Host Path | Container Path |
|:----------:|:---------------:|:-------:|:---------:|:--------------:|
| `80`, `443`, `81` | `80`, `443`, `81` | `mistia-proxy-net`<br>`nginx-proxy-net` | `nginx-proxy/data`<br>`nginx-proxy/letsencrypt` | `/data`<br>`/etc/letsencrypt` |
| `N/A` | `3306` | `nginx-proxy-net` | `nginx-proxy/db_data` | `/var/lib/mysql` |

## 📋 Prerequisites

- **Cloudflare API Token**: For automatic HTTPS certificate issuance using Let's Encrypt via the DNS-01 challenge.

!!! note "mistia-proxy-net"
    The `mistia-proxy-net` network will be created by this container

## 🔧 Configuration

### 📂 Host Directory

```text
mistia-nexus/
└── nginx-proxy/
    ├── .env                  # Application secrets
    ├── docker-compose.yml    # Defines the Nginx Proxy Manager service, network, and volumes
    ├── data/                 # Mapped volume
    ├── db_data/              # Mapped volume
    └── letsencrypt/          # Mapped volume
```

### 📁 Container Directory

```text
# For the nginx-proxy container
/
└── /data             # Nginx configurations and proxy host data
└── /etc/letsencrypt  # SSL certificates from Let's Encrypt

# For the nginx-proxy-db container
/var/lib/mysql        # MariaDB database files
```

### 🐋 Docker Compose

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/nginx-proxy/docker-compose.yml"
```

### 📄 Application Secret

Create this `.env` file in the deployment location.

```bash
cd /volume2/docker/mistia-nexus/nginx-proxy
sudo nano .env
```

```text title=".env"
DB_PASSWORD=[secret-here]
DB_ROOT_PASSWORD=[secret-here]
```

++ctrl+x++ &nbsp;&nbsp;&nbsp; ++y++ &nbsp;&nbsp;&nbsp; ++enter++ &nbsp;&nbsp;&nbsp; to save and exit

## ✨ Initial Deployment

```bash
cd /volume2/docker/mistia-nexus/
./script/update.sh nginx-proxy
```

## 🚀 Initial Setup

### 🪪 Account Setup

1. Navigate to [http://192.168.50.4:81](http://192.168.50.4:81)

2. Log in with the default administrator account:
    - **Email:** `admin@example.com`
    - **Password:** `changeme`

3. You will be prompted to change your username and password immediately

### 🎀 Setup SSL Certificate

1. Navigate to `SSL Certificates`
      - Click on the `SSL Certificates` tab
      - Click `Add SSL Certificate` and select `Let's Encrypt`

2. Fill out the Certificate Details:
      - **Domain Names:**
        - Type `mistia.xyz`, press `Enter`
        - Type `*.mistia.xyz` and press `Enter`
      - **Use a DNS Challenge:** `ON`
      - **DNS Provider:** `Cloudflare`
      - **Credentials File Content:**
        - Replace `<YOUR_CLOUDFLARE_API_TOKEN>` with the token you copied from Cloudflare

        ```txt
        dns_cloudflare_api_token = <YOUR_CLOUDFLARE_API_TOKEN>
        ```

      - Agree to the **Let's Encrypt Terms of Service**
      - Click `Save`

### ⚙️ Add Proxy Hosts

1. Begin adding your proxy hosts and SSL certificates through the web interface

2. Navigate to `Hosts` >> `Proxy Hosts`

3. Click `Add Proxy Host` (e.g. portainer)
    - `Details` Tab:
        - **Domain Names:** `portainer.mistia.xyz`
        - **Scheme:** `http`
        - **Forward Hostname / IP:** `portainer`
        - **Forward Port:** `9000`
        - Enable `Block Common Exploits`
    - `SSL` Tab:
        - **SSL Certificate:** Select your `*.mistia.xyz` certificate from the dropdown list.
        - Enable `Force SSL`
        - Enable `HSTS Enabled`
        - Enable `HTTP/2 Support`
    - Click `Save`
