# Security Hardening

## Overview

Comprehensive security hardening procedures for Mistia-Nexus infrastructure to minimize attack surface and strengthen defensive capabilities.

## System Hardening

### Docker Security

#### Container Configuration

```yaml
# Security-focused docker-compose.yml
version: '3.8'
services:
  service-name:
    # Run as non-root user
    user: "1000:1000"
    
    # Security options
    security_opt:
      - no-new-privileges:true
      - apparmor:docker-default
    
    # Read-only root filesystem
    read_only: true
    
    # Temporary filesystems
    tmpfs:
      - /tmp:noexec,nosuid,size=100m
      - /var/tmp:noexec,nosuid,size=50m
    
    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          memory: 256M
    
    # Drop all capabilities, add only required ones
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
```

#### Network Security

```yaml
# Create isolated networks
networks:
  frontend:
    driver: bridge
    internal: false  # Internet access via proxy only
  backend:
    driver: bridge
    internal: true   # No internet access
```

### Host System Hardening

#### SSH Configuration

```bash
# /etc/ssh/sshd_config
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers your-username
```

#### Firewall Rules

```bash
# UFW configuration
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 53/tcp
ufw allow 53/udp
ufw enable
```

#### Fail2Ban Configuration

```ini
# /etc/fail2ban/jail.local
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
```

## Application Security

### Caddy Security Headers

```caddyfile
# Security headers for all sites
(security_headers) {
    header {
        # HSTS
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        
        # Content Security Policy
        Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'"
        
        # Other security headers
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
        Permissions-Policy "geolocation=(), microphone=(), camera=()"
        
        # Remove server information
        -Server
        -X-Powered-By
    }
}

# Apply to all sites
*.homelab.local {
    import security_headers
    # ... rest of configuration
}
```

### Database Security

```yaml
# PostgreSQL security configuration
environment:
  POSTGRES_DB: ${DB_NAME}
  POSTGRES_USER: ${DB_USER}
  POSTGRES_PASSWORD_FILE: /run/secrets/db_password
  POSTGRES_INITDB_ARGS: "--auth-host=scram-sha-256 --auth-local=scram-sha-256"

secrets:
  db_password:
    file: ./secrets/db_password.txt

volumes:
  - db_data:/var/lib/postgresql/data:Z
```

## Secret Management

### Docker Secrets

```bash
# Create secrets directory
mkdir -p ./secrets
chmod 700 ./secrets

# Generate strong passwords
openssl rand -base64 32 > ./secrets/db_password.txt
openssl rand -base64 32 > ./secrets/admin_password.txt

# Set proper permissions
chmod 600 ./secrets/*.txt
```

### Environment Variables

```bash
# .env file security
chmod 600 .env

# Example secure .env
DB_USER=app_user
DB_NAME=application_db
ADMIN_EMAIL=admin@yourdomain.com
BACKUP_ENCRYPTION_KEY_FILE=/run/secrets/backup_key
```

## Monitoring and Alerting

### Log Monitoring

```yaml
# Centralized logging with security focus
version: '3.8'
services:
  logspout:
    image: gliderlabs/logspout:latest
    command: syslog://logserver:514
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    depends_on:
      - logserver
```

### Intrusion Detection

```bash
# AIDE configuration for file integrity monitoring
aide --init
aide --check

# Automated checks via cron
echo "0 2 * * * /usr/bin/aide --check" | crontab -
```

### Security Scanning

```bash
# Docker image vulnerability scanning
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image caddy:latest

# Container runtime security
docker run --rm --cap-add SYS_ADMIN \
  --pid host --net host \
  aquasec/kube-bench:latest
```

## Backup Security

### Encrypted Backups

```bash
#!/bin/bash
# Secure backup script

BACKUP_DIR="/var/backups/mistia-nexus"
ENCRYPTION_KEY="/etc/backup/encryption.key"
DATE=$(date +%Y%m%d_%H%M%S)

# Create encrypted backup
tar czf - /path/to/data | \
gpg --cipher-algo AES256 --compress-algo 1 --symmetric \
    --passphrase-file "$ENCRYPTION_KEY" \
    --output "$BACKUP_DIR/backup_$DATE.tar.gz.gpg"

# Verify backup integrity
gpg --passphrase-file "$ENCRYPTION_KEY" --decrypt \
    "$BACKUP_DIR/backup_$DATE.tar.gz.gpg" | \
    tar tzf - > /dev/null

if [ $? -eq 0 ]; then
    echo "Backup verification successful"
else
    echo "Backup verification failed" >&2
    exit 1
fi
```

### Backup Rotation

```bash
# Automated backup rotation
find "$BACKUP_DIR" -name "backup_*.tar.gz.gpg" -mtime +30 -delete

# Keep last 7 daily, 4 weekly, 12 monthly backups
# (Implementation depends on backup strategy)
```

## Access Control

### Multi-Factor Authentication

```yaml
# Authelia configuration example
version: '3.8'
services:
  authelia:
    image: authelia/authelia:latest
    container_name: authelia
    volumes:
      - ./authelia:/config
    environment:
      - TZ=UTC
    restart: unless-stopped
    networks:
      - mistia-network
```

### Role-Based Access

```yaml
# Portainer RBAC example
users:
  - username: admin
    role: administrator
  - username: operator
    role: operator
    teams:
      - homelab-ops
```

## Incident Response

### Automated Response

```bash
#!/bin/bash
# Security incident response script

INCIDENT_TYPE="$1"
AFFECTED_SERVICE="$2"

case "$INCIDENT_TYPE" in
    "intrusion")
        # Isolate affected containers
        docker network disconnect mistia-network "$AFFECTED_SERVICE"
        # Capture forensic data
        docker logs "$AFFECTED_SERVICE" > "/var/log/incident_${AFFECTED_SERVICE}.log"
        # Alert administrators
        echo "Security incident detected" | mail -s "SECURITY ALERT" admin@yourdomain.com
        ;;
    "malware")
        # Stop affected service
        docker stop "$AFFECTED_SERVICE"
        # Quarantine container
        docker rename "$AFFECTED_SERVICE" "${AFFECTED_SERVICE}_quarantine"
        ;;
esac
```

### Emergency Procedures

1. **Immediate Isolation**

   ```bash
   # Disconnect from networks
   docker network disconnect mistia-network service-name
   
   # Stop all services if necessary
   cd /path/to/mistia-nexus && docker-compose down
   ```

2. **Evidence Preservation**

   ```bash
   # Capture container state
   docker commit service-name evidence-snapshot
   
   # Export logs
   docker logs service-name > incident-logs.txt
   ```

3. **Communication Plan**
   - Internal team notification
   - Stakeholder updates
   - External reporting (if required)

## Compliance and Auditing

### Audit Logging

```yaml
# Comprehensive audit logging
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
    labels: "service,environment"
```

### Compliance Checks

```bash
# Regular security checklist
- [ ] All containers running as non-root
- [ ] Security updates applied
- [ ] Certificates valid and current
- [ ] Backup encryption working
- [ ] Access logs reviewed
- [ ] Vulnerability scans completed
- [ ] Incident response plan tested
```

## Automation Scripts

### Security Update Script

```bash
#!/bin/bash
# Automated security updates

# Update system packages
apt update && apt upgrade -y

# Update Docker images
docker-compose pull
docker-compose up -d

# Clean up old images
docker image prune -a -f

# Restart security services
systemctl restart fail2ban
systemctl restart ufw
```

### Health Check Script

```bash
#!/bin/bash
# Security health check

FAILED_CHECKS=0

# Check if all services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "WARNING: Some services are not running"
    ((FAILED_CHECKS++))
fi

# Check SSL certificates
if ! openssl s_client -connect localhost:443 -servername homelab.local < /dev/null 2>/dev/null | \
     openssl x509 -checkend 2592000 -noout; then
    echo "WARNING: SSL certificate expires within 30 days"
    ((FAILED_CHECKS++))
fi

# Check for security updates
if apt list --upgradable 2>/dev/null | grep -q security; then
    echo "WARNING: Security updates available"
    ((FAILED_CHECKS++))
fi

exit $FAILED_CHECKS
```
