# Caddyfile Snippets

## Overview

This document provides reusable Caddyfile snippets and templates for common configurations in the Mistia-Nexus homelab environment.

## Basic Service Template

### Standard Reverse Proxy

```caddyfile
# Basic reverse proxy for internal service
servicename.yourdomain.com {
    reverse_proxy servicename:8080
    
    # Security headers
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        X-XSS-Protection "1; mode=block"
        Referrer-Policy strict-origin-when-cross-origin
    }
    
    # Access logging
    log {
        output file /var/log/caddy/servicename.log
        format json
    }
}
```

### Service with Authentication

```caddyfile
# Service with basic authentication
protected.yourdomain.com {
    # Basic authentication
    basicauth /* {
        admin $2a$14$[bcrypt-hash-here]
    }
    
    reverse_proxy protected-service:8080
    
    # Rate limiting for auth endpoints
    rate_limit {
        zone protected {
            key {remote_host}
            events 10
            window 1m
        }
    }
}
```

## Security Snippets

### Security Headers

```caddyfile
# Reusable security headers snippet
(security_headers) {
    header {
        # Prevent MIME type sniffing
        X-Content-Type-Options nosniff
        
        # Prevent clickjacking
        X-Frame-Options DENY
        
        # XSS protection
        X-XSS-Protection "1; mode=block"
        
        # Referrer policy
        Referrer-Policy strict-origin-when-cross-origin
        
        # Content Security Policy (customize per service)
        Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"
        
        # Strict Transport Security (HTTPS only)
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        
        # Remove server identification
        -Server
    }
}

# Usage in service config:
service.yourdomain.com {
    import security_headers
    reverse_proxy service:8080
}
```

### Rate Limiting

```caddyfile
# Basic rate limiting
(rate_limit_basic) {
    rate_limit {
        zone basic {
            key {remote_host}
            events 100
            window 1m
        }
    }
}

# Strict rate limiting for sensitive services
(rate_limit_strict) {
    rate_limit {
        zone strict {
            key {remote_host}
            events 10
            window 1m
        }
    }
}

# API rate limiting
(rate_limit_api) {
    rate_limit {
        zone api {
            key {remote_host}
            events 1000
            window 1h
        }
    }
}
```

### IP Restrictions

```caddyfile
# Local network only access
(local_only) {
    @notlocal {
        not remote_ip 192.168.50.0/24
        not remote_ip 127.0.0.1
    }
    respond @notlocal "Access denied" 403
}

# Admin IP restrictions
(admin_only) {
    @notadmin {
        not remote_ip 192.168.50.100  # Admin workstation
        not remote_ip 192.168.50.101  # Admin laptop
    }
    respond @notadmin "Access denied" 403
}
```

## Service-Specific Snippets

### Docker Management (Portainer)

```caddyfile
portainer.yourdomain.com {
    # Local network access only
    @notlocal {
        not remote_ip 192.168.50.0/24
    }
    respond @notlocal "Access denied" 403
    
    reverse_proxy portainer:9000
    
    # Enhanced security for management interface
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options SAMEORIGIN  # Allow framing for embedded views
        X-XSS-Protection "1; mode=block"
        Referrer-Policy strict-origin-when-cross-origin
        -Server
    }
    
    # Stricter rate limiting
    rate_limit {
        zone portainer {
            key {remote_host}
            events 50
            window 1m
        }
    }
    
    log {
        output file /var/log/caddy/portainer.log
        format json
    }
}
```

### DNS Management (AdGuard Home)

```caddyfile
adguard.yourdomain.com {
    # Admin access only
    @notadmin {
        not remote_ip 192.168.50.100
        not remote_ip 192.168.50.101
    }
    respond @notadmin "Access denied" 403
    
    reverse_proxy adguard-home:3000
    
    # Security headers
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        X-XSS-Protection "1; mode=block"
        Referrer-Policy strict-origin-when-cross-origin
        -Server
    }
    
    # Rate limiting for admin interface
    rate_limit {
        zone adguard {
            key {remote_host}
            events 20
            window 1m
        }
    }
    
    log {
        output file /var/log/caddy/adguard.log
        format json
    }
}
```

### Backup Management (Duplicati)

```caddyfile
duplicati.yourdomain.com {
    # Local network access only
    @notlocal {
        not remote_ip 192.168.50.0/24
    }
    respond @notlocal "Access denied" 403
    
    reverse_proxy duplicati:8200
    
    # Allow larger uploads for backup configurations
    request_body {
        max_size 100MB
    }
    
    # Extended timeout for backup operations
    reverse_proxy duplicati:8200 {
        timeout 300s
    }
    
    # Security headers
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        X-XSS-Protection "1; mode=block"
        Referrer-Policy strict-origin-when-cross-origin
        -Server
    }
    
    log {
        output file /var/log/caddy/duplicati.log
        format json
    }
}
```

### Documentation (MkDocs)

```caddyfile
docs.yourdomain.com {
    reverse_proxy mkdocs:8000
    
    # Caching for static documentation
    @static {
        path *.css *.js *.png *.jpg *.gif *.ico *.woff *.woff2
    }
    header @static Cache-Control "public, max-age=31536000, immutable"
    
    # Security headers (relaxed for documentation)
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options SAMEORIGIN  # Allow embedding
        X-XSS-Protection "1; mode=block"
        Referrer-Policy strict-origin-when-cross-origin
        -Server
    }
    
    # Generous rate limiting for documentation
    rate_limit {
        zone docs {
            key {remote_host}
            events 200
            window 1m
        }
    }
    
    log {
        output file /var/log/caddy/docs.log
        format json
    }
}
```

## Development Snippets

### Development Mode

```caddyfile
# Development configuration with relaxed security
(dev_mode) {
    # Allow CORS for development
    header {
        Access-Control-Allow-Origin "*"
        Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Access-Control-Allow-Headers "Content-Type, Authorization"
    }
    
    # Disable caching
    header Cache-Control "no-cache, no-store, must-revalidate"
    
    # Less strict rate limiting
    rate_limit {
        zone dev {
            key {remote_host}
            events 1000
            window 1m
        }
    }
}
```

### Local Development

```caddyfile
# Local development domains
*.local {
    tls internal
    
    @adguard host adguard.local
    handle @adguard {
        reverse_proxy adguard-home:3000
    }
    
    @portainer host portainer.local
    handle @portainer {
        reverse_proxy portainer:9000
    }
    
    @duplicati host duplicati.local
    handle @duplicati {
        reverse_proxy duplicati:8200
    }
    
    @docs host docs.local
    handle @docs {
        reverse_proxy mkdocs:8000
    }
    
    # Default response
    respond "Service not found" 404
}
```

## Advanced Configurations

### Load Balancing

```caddyfile
# Load balancing between multiple instances
service.yourdomain.com {
    reverse_proxy {
        to service1:8080
        to service2:8080
        
        # Health checks
        health_uri /health
        health_interval 30s
        health_timeout 5s
        
        # Load balancing method
        lb_policy round_robin
    }
}
```

### WebSocket Support

```caddyfile
# Service with WebSocket support
websocket-service.yourdomain.com {
    reverse_proxy service:8080 {
        # Enable WebSocket upgrades
        upgrade_websocket
        
        # Extended timeout for WebSocket connections
        timeout 0
    }
}
```

### File Server

```caddyfile
# Static file server
files.yourdomain.com {
    root * /var/www/files
    file_server browse
    
    # Security for file server
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        -Server
    }
    
    # Prevent access to sensitive files
    @sensitive {
        path *.env *.key *.pem *.conf
    }
    respond @sensitive 403
}
```

## SSL/TLS Configurations

### Custom SSL Configuration

```caddyfile
# Custom TLS settings
service.yourdomain.com {
    tls {
        protocols tls1.2 tls1.3
        ciphers TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        curves x25519 secp384r1
    }
    
    reverse_proxy service:8080
}
```

### Let's Encrypt Configuration

```caddyfile
# Explicit Let's Encrypt configuration
service.yourdomain.com {
    tls {
        issuer acme {
            dir https://acme-v02.api.letsencrypt.org/directory
            email admin@yourdomain.com
        }
    }
    
    reverse_proxy service:8080
}
```

## Monitoring and Logging

### Detailed Logging

```caddyfile
# Enhanced logging configuration
(enhanced_logging) {
    log {
        output file /var/log/caddy/{host}.log {
            roll_size 100MB
            roll_keep 5
            roll_keep_for 7d
        }
        format json
        level INFO
        include http.request.headers.User-Agent
        include http.request.headers.X-Forwarded-For
    }
}
```

### Health Check Endpoint

```caddyfile
# Health check endpoint
yourdomain.com {
    handle /health {
        respond "OK" 200
    }
    
    handle {
        reverse_proxy main-service:8080
    }
}
```

### Metrics Endpoint

```caddyfile
# Prometheus metrics (if metrics plugin enabled)
:2019 {
    metrics /metrics
    
    # Restrict access to metrics
    @notlocal {
        not remote_ip 192.168.50.0/24
    }
    respond @notlocal "Access denied" 403
}
```

## Error Handling

### Custom Error Pages

```caddyfile
# Custom error pages
service.yourdomain.com {
    reverse_proxy service:8080
    
    # Custom error handling
    handle_errors {
        @5xx expression {http.error.status_code} >= 500
        handle @5xx {
            rewrite * /50x.html
            file_server {
                root /var/www/errors
            }
        }
        
        @4xx expression {http.error.status_code} >= 400
        handle @4xx {
            rewrite * /40x.html
            file_server {
                root /var/www/errors
            }
        }
    }
}
```

### Fallback Configuration

```caddyfile
# Fallback for undefined services
yourdomain.com {
    # Main service
    handle /api/* {
        reverse_proxy api-service:8080
    }
    
    handle /docs/* {
        reverse_proxy docs-service:8000
    }
    
    # Fallback to default service
    handle {
        reverse_proxy default-service:80
    }
}
```

## Testing Snippets

### Testing Configuration

```caddyfile
# Test configuration validation
# Run: caddy validate --config Caddyfile
test.local {
    respond "Test configuration" 200
    
    header {
        Content-Type "text/plain"
        X-Test "true"
    }
}
```

### Debug Configuration

```caddyfile
# Debug mode with verbose logging
debug.local {
    log {
        level DEBUG
        output stdout
    }
    
    reverse_proxy service:8080 {
        # Log all headers
        header_up X-Debug "true"
        header_down X-Debug-Response "true"
    }
}
```
