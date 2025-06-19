---
icon: simple/docker
---

# 📝 Docker Compose Template

!!! abstract "Overview"
    This template ensures all services follow the same conventions and standards.

```yaml title="docker-compose.yml"
--8<-- "docs/content/.snippets/docker-compose.yml"
```

## 🔐 Security Templates

### High Security Service

```yaml
services:
  secure-service:
    image: secure-app:latest
    container_name: secure-service
    hostname: secure-service
    
    # Enhanced security settings
    user: "1001:1001"               # Non-root user
    read_only: true                 # Read-only filesystem
    
    # Security capabilities
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE             # Only if needed for port binding
    
    # Security options
    security_opt:
      - no-new-privileges:true
    
    logging:
      driver: 'json-file'
      options:
        max-size: '10m'
        max-file: '3'
    
    healthcheck:
      test: ['CMD-SHELL', 'curl -f http://localhost:8080/health || exit 1']
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    
    labels:
      - 'com.mistia-nexus.service.name=Secure Service'
      - 'com.mistia-nexus.service.type=Application'
      - 'com.mistia-nexus.security.level=high'
    
    environment:
      - TZ=Asia/Singapore
    
    volumes:
      - ./data:/data
      - ./config:/config:ro           # Read-only configuration
      - /tmp:/tmp                     # Writable temp directory
    
    dns:
      - 192.168.50.251
    restart: unless-stopped
    networks:
      - mistia-proxy-net

networks:
  mistia-proxy-net:
    name: mistia-proxy-net
    external: true
```
