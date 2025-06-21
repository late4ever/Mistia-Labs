---
icon: simple/stremio
---

# :simple-stremio:{ .stremio } Stremio

<!-- markdownlint-disable MD033 -->

!!! abstract "Overview"
    Stremio is a modern media center that gives you the freedom to watch everything you want. How does it work? Once you install Stremio on your device and create an account, all you have to do is to visit the addon catalog and install any addon you want.

## 📑 Service Information

:material-web: [https://stremio.mistia.xyz](https://stremio.mistia.xyz)

:fontawesome-regular-id-badge: stremio &nbsp;&nbsp;&nbsp; :fontawesome-brands-docker: stremio/server:latest

| Host Ports | Container Ports | Network | Host Path | Container Path |
|:----------:|:---------------:|:-------:|:---------:|:--------------:|
| *proxied* | `11470` | `mistia-proxy-net` | `stremio-cache` (named volume)<br>`stremio/config` | `/opt/stremio-cache`<br>`/root/.stremio-server` |

## 📋 Prerequisites

- The `mistia-proxy-net` network must be available.

## 🔧 Configuration

### 📂 Host Directory

```text
mistia-nexus/
└── stremio/
    ├── docker-compose.yml  # Defines the Stremio service, network, and volumes
    └── config/             # Server configuration files

# Docker-Managed Volume
stremio-cache               # Named volume for media cache
└── /var/lib/docker/volumes/stremio_stremio-cache/_data/
```

### 📁 Container Directory

```text
/
├── opt/stremio-cache/          # Media cache (Docker-managed volume)
└── root/.stremio-server/       # Server configuration (bind mount)
```

### 🐋 Docker Compose

Retrieve the PUID and PGID values for the `docker-compose.yml`

```bash
--8<-- "docs/content/.snippets/ssh.sh:sshid"
```

```yaml title="docker-compose.yml"
--8<-- "mistia-nexus/stremio/docker-compose.yml"
```

### 🔀 Reverse Proxy

```caddyfile title="Caddyfile"
--8<-- "mistia-nexus/caddy/Caddyfile:stremio"
```

### 📄 Application Secret

```text
not needed
```

## ✨ Initial Deployment

```bash
cd /volume2/docker/mistia-nexus/
./scripts/add-service.sh stremio
```

## 🚀 Initial Setup

### 🪪 Account Setup

1. Navigate to [https://stremio.mistia.xyz](https://stremio.mistia.xyz)

2. Create a Stremio account or log in with existing credentials

3. Install Stremio client applications on your devices and connect to your self-hosted server

### 📝 DNS Rewrite

1. Navigate to [https://adguard.mistia.xyz](https://adguard.mistia.xyz) >> `Filters` >> `DNS rewrites`

2. Click `Add DNS rewrite`
      - **Domain**: `stremio.mistia.xyz`
      - **Answer**: `192.168.50.4`
      - Click `Save`

3. Navigate to [https://stremio.mistia.xyz](https://stremio.mistia.xyz) to verify

### ⚙️ Addon Installation

1. In the Stremio interface, navigate to the addon catalog

2. Install **Essential Addons:**
   - **Torrentio** - Primary torrent addon with Real-Debrid integration
   - **Cinemeta** - Official metadata provider (movies/TV shows info)
   - **WatchHub** - Tracks your viewing progress across devices

3. Install **Premium Service Addons:**
   - **Real-Debrid** - Premium cached torrents and direct links
   - **AllDebrid** - Alternative premium service to Real-Debrid
   - **Premiumize** - Another premium caching service

4. Install **Asian Content Addons (Netflix Singapore Replacement):**
   - **Korean Drama & Movies:**
     - **Dramacool** - Extensive K-drama collection with subtitles
     - **KissAsian** - Korean movies and variety shows
     - **Viki** - Official Korean content with professional subtitles
   - **Japanese Content:**
     - **DramaNice** - J-dramas and Japanese movies
     - **KissAsian** - Japanese dramas and variety content
   - **Anime Content:**
     - **Anime Kitsu** - Comprehensive anime database
     - **9anime** - Large anime collection with multiple sources
     - **Gogoanime** - Popular anime streaming addon
     - **AnimePahe** - High-quality anime with smaller file sizes
   - **Chinese Content:**
     - **DramaCool** - Chinese dramas and movies
     - **iQiYi** - Official Chinese streaming content
   - **Southeast Asian Content:**
     - **iflix** - Regional content including Singaporean shows
     - **Viu** - Asian entertainment platform content
     - **WeTV** - Asian dramas and entertainment

5. Install **Live Sports Addons:**
   - **SportHD** - Live sports streams including Asian leagues
   - **Live Sports on TV** - Comprehensive sports coverage
   - **CricHD** - Cricket and other sports (popular in Singapore)
   - **Sport365** - Football, basketball, tennis, and more
   - **IPTV Sports** - Various sports channels and events
   - **Reddit Sports** - Community-sourced sports streams

6. Install **Content Discovery Addons:**
   - **IMDB Lists** - Curated movie/TV collections from IMDB
   - **Trakt** - Sync watchlists and recommendations
   - **MyDramaList** - Asian drama discovery and tracking
   - **Letterboxd** - Movie recommendations from cinephiles
   - **Anime-Planet** - Anime recommendations and tracking

7. Install **Specialized Content Addons:**
   - **YouTube** - YouTube videos and channels
   - **Twitch** - Live gaming and entertainment streams
   - **Local Singapore Content:**
     - **Toggle** - Mediacorp content (if available)
     - **OKTO** - Educational and documentary content

8. Install **Subtitle Addons:**
   - **OpenSubtitles** - Large subtitle database
   - **Addic7ed** - TV show subtitles
   - **Local Files** - For your own subtitle files

### 📋 Addon Configuration Tips

**For Torrentio:**

- Enable Real-Debrid integration in settings
- Configure quality preferences (4K, 1080p, etc.)
- Set language preferences for content

**For Real-Debrid:**

- Sign up at [real-debrid.com](https://real-debrid.com)
- Generate API key from your account
- Enter API key in Torrentio addon settings

**For Trakt:**

- Create account at [trakt.tv](https://trakt.tv)
- Authorize Stremio integration
- Sync your viewing history and watchlists

**For Asian Content Addons:**

- Set subtitle preferences to English for Korean/Japanese content
- Configure quality preferences (many Asian shows available in 1080p)
- Enable auto-play for binge-watching dramas
- Use MyDramaList integration for drama tracking and recommendations

**For Live Sports:**

- Check time zones for live events (Singapore is GMT+8)
- Use multiple sports addons as backup sources
- Consider VPN if geo-blocking affects certain streams
- Set notification preferences for favorite teams/leagues

**For Singapore-Specific Content:**

- Look for Toggle and OKTO addon alternatives in community repositories
- Check YouTube addon for local Singapore content creators
- Use regional IPTV sources for local news and entertainment

