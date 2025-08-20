# Files Directory

## Zweck
Das `files/` Verzeichnis enthält statische Dateien, die unverändert auf Ziel-Hosts kopiert werden.

## Was sind Files:
Files sind statische Dateien (Skripte, Konfigurationsdateien, Binaries, etc.), die mit dem `copy` oder `file` Modul auf Ziel-Systeme übertragen werden, ohne dass sie durch Template-Engine verarbeitet werden.

## Was gehört hier rein:
- **Konfigurationsdateien** (nginx.conf, sshd_config)
- **Shell-Skripte** (backup.sh, monitoring.sh)
- **Binary-Dateien** (executables, packages)
- **SSL-Zertifikate** (certificates, keys)
- **Init-Scripts** (systemd service files)
- **Static Content** (HTML, CSS, JS Dateien)

## Verzeichnisstruktur:
```
files/
├── scripts/
│   ├── backup.sh          # Backup-Skript
│   ├── health-check.sh    # System-Monitoring
│   └── deploy.sh          # Deployment-Skript
├── configs/
│   ├── nginx/
│   │   ├── nginx.conf     # Nginx Haupt-Config
│   │   └── sites/         # Site-Konfigurationen
│   ├── ssh/
│   │   └── sshd_config    # SSH-Konfiguration
│   └── systemd/
│       └── myapp.service  # Systemd Service
├── ssl/
│   ├── certificates/
│   └── ca-bundle.crt      # CA-Zertifikate
├── keys/
│   ├── app-signing.key    # Application Keys
│   └── README.txt         # Key-Dokumentation
└── packages/
    └── custom-app.deb     # Custom Packages
```

## Verwendung in Tasks:
```yaml
# Einfaches Kopieren
- name: Copy backup script
  copy:
    src: scripts/backup.sh
    dest: /usr/local/bin/backup.sh
    mode: '0755'
    owner: root
    group: root

# Mit Backup
- name: Copy nginx configuration
  copy:
    src: configs/nginx/nginx.conf
    dest: /etc/nginx/nginx.conf
    backup: yes
    mode: '0644'
  notify: restart nginx

# Verzeichnis kopieren
- name: Copy nginx site configs
  copy:
    src: configs/nginx/sites/
    dest: /etc/nginx/sites-available/
    mode: '0644'

# Binary mit speziellen Berechtigungen
- name: Install custom binary
  copy:
    src: packages/myapp
    dest: /usr/local/bin/myapp
    mode: '0755'
    owner: myapp
    group: myapp
```

## File-Kategorien:

### 1. Konfigurationsdateien:
```
files/configs/
├── nginx/
│   ├── nginx.conf         # Haupt-Konfiguration
│   ├── mime.types         # MIME-Types
│   └── sites/
│       ├── default        # Default Site
│       └── api.conf       # API-Konfiguration
├── apache/
│   ├── apache2.conf
│   └── sites/
├── mysql/
│   └── my.cnf
└── docker/
    └── daemon.json
```

### 2. Skripte:
```
files/scripts/
├── backup/
│   ├── mysql-backup.sh    # MySQL Backup
│   ├── files-backup.sh    # File Backup
│   └── cleanup.sh         # Cleanup-Routine
├── monitoring/
│   ├── health-check.sh    # Health Check
│   ├── disk-usage.sh      # Disk Monitoring
│   └── log-rotate.sh      # Log Rotation
├── deployment/
│   ├── deploy-app.sh      # App Deployment
│   ├── rollback.sh        # Rollback Script
│   └── pre-deploy.sh      # Pre-deployment
└── maintenance/
    ├── update-system.sh   # System Updates
    └── restart-services.sh # Service Restart
```

### 3. Systemd Services:
```
files/systemd/
├── myapp.service          # Custom Application
├── backup.service         # Backup Service
├── backup.timer           # Backup Timer
├── monitoring.service     # Monitoring Service
└── log-cleaner.service    # Log Cleanup
```

### 4. SSL/Security:
```
files/ssl/
├── certificates/
│   ├── domain.crt         # SSL Certificates
│   ├── wildcard.crt       # Wildcard Certificate
│   └── ca-bundle.crt      # CA Bundle
├── keys/
│   ├── domain.key         # Private Keys (verschlüsselt!)
│   └── signing.key        # Signing Keys
└── configs/
    ├── ssl.conf           # SSL-Konfiguration
    └── ciphers.conf       # Cipher-Suites
```

## Beispiel-Dateien:

### files/scripts/backup.sh:
```bash
#!/bin/bash
# System Backup Script

set -e

BACKUP_DIR="/mnt/backup"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/log/backup.log"

echo "Starting backup at $(date)" >> "$LOG_FILE"

# MySQL Backup
mysqldump --all-databases > "$BACKUP_DIR/mysql_$DATE.sql"

# File Backup
tar czf "$BACKUP_DIR/files_$DATE.tar.gz" /etc /var/www /home

# Cleanup old backups (keep 7 days)
find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed at $(date)" >> "$LOG_FILE"
```

### files/systemd/myapp.service:
```ini
[Unit]
Description=My Application Service
After=network.target
Requires=network.target

[Service]
Type=simple
User=myapp
Group=myapp
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/myapp
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### files/configs/nginx/nginx.conf:
```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                   '$status $body_bytes_sent "$http_referer" '
                   '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;
    
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    gzip on;
    
    include /etc/nginx/sites-enabled/*;
}
```

## Files vs. Templates:
| Aspekt | Files | Templates |
|--------|-------|-----------|
| **Inhalt** | Statisch | Dynamisch |
| **Variablen** | Keine | Jinja2-Variablen |
| **Verarbeitung** | Direkt kopiert | Template-Engine |
| **Verwendung** | Unveränderte Dateien | Konfiguration mit Variablen |
| **Beispiel** | Binary, SSL-Cert | nginx.conf mit {{ variables }} |

## Best Practices:
- **Versionierung**: Wichtige Dateien in Git verwalten
- **Berechtigungen**: Sichere Default-Permissions setzen
- **Backup**: Immer backup=yes für wichtige Configs
- **Validierung**: Konfigurationsdateien vor Copy validieren
- **Dokumentation**: README für komplexe Datei-Strukturen
- **Sicherheit**: Keine privaten Keys im Klartext
- **Organisation**: Logische Verzeichnisstruktur verwenden

## Sicherheitshinweise:
```yaml
# SCHLECHT: Private Keys im Klartext
- copy:
    src: ssl/private.key
    dest: /etc/ssl/private.key

# BESSER: Verschlüsselte Keys mit Vault
- copy:
    content: "{{ vault_private_key }}"
    dest: /etc/ssl/private.key
    mode: '0600'

# ODER: Keys extern verwalten
- copy:
    src: "{{ inventory_hostname }}/ssl/private.key"
    dest: /etc/ssl/private.key
    mode: '0600'
```

## Debugging:
```bash
# Datei-Quelle überprüfen
ansible-playbook playbooks/site.yml --check --diff

# Copy-Aufgabe testen
ansible hostname -m copy -a "src=scripts/test.sh dest=/tmp/test.sh mode=0755"

# Dateiberechtigungen prüfen
ansible hostname -m stat -a "path=/usr/local/bin/backup.sh"
```
