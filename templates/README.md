# Templates Directory

## Zweck
Das `templates/` Verzeichnis enthält Jinja2-Templates, die zur Laufzeit mit Variablen gefüllt und dann auf Ziel-Hosts kopiert werden.

## Was sind Templates:
Templates sind Konfigurationsdateien mit Platzhaltern (Jinja2-Syntax), die durch Ansible-Variablen ersetzt werden. Sie ermöglichen dynamische, variablen-basierte Konfiguration.

## Template-Sprache: Jinja2
Ansible nutzt Jinja2 als Template-Engine mit folgenden Features:
- **Variablen**: `{{ variable_name }}`
- **Bedingungen**: `{% if condition %}`
- **Schleifen**: `{% for item in list %}`
- **Filter**: `{{ variable | filter }}`
- **Kommentare**: `{# comment #}`

## Verzeichnisstruktur:
```
templates/
├── nginx/
│   ├── nginx.conf.j2      # Nginx Haupt-Konfiguration
│   ├── site.conf.j2       # Site-Template
│   └── ssl.conf.j2        # SSL-Konfiguration
├── systemd/
│   ├── service.j2         # Systemd Service Template
│   └── timer.j2           # Systemd Timer Template
├── scripts/
│   ├── backup.sh.j2       # Backup-Skript Template
│   └── monitoring.sh.j2   # Monitoring-Skript
├── docker/
│   ├── docker-compose.yml.j2
│   └── Dockerfile.j2
├── configs/
│   ├── hosts.j2           # /etc/hosts Template
│   ├── resolv.conf.j2     # DNS-Konfiguration
│   └── crontab.j2         # Crontab Template
└── apps/
    ├── app-config.json.j2 # Application Config
    └── database.yml.j2    # Database Config
```

## Verwendung in Tasks:
```yaml
# Einfaches Template
- name: Configure nginx
  template:
    src: nginx/nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    backup: yes
    mode: '0644'
  notify: restart nginx

# Template mit Variablen
- name: Create systemd service
  template:
    src: systemd/service.j2
    dest: "/etc/systemd/system/{{ service_name }}.service"
    mode: '0644'
  notify: reload systemd

# Template mit Validierung
- name: Configure application
  template:
    src: apps/app-config.json.j2
    dest: "/opt/{{ app_name }}/config.json"
    mode: '0644'
    owner: "{{ app_user }}"
    group: "{{ app_group }}"
    validate: "python3 -m json.tool %s"
```

## Template-Beispiele:

### templates/nginx/nginx.conf.j2:
```nginx
# Ansible managed - Do not edit manually
user {{ nginx_user | default('www-data') }};
worker_processes {{ nginx_worker_processes | default('auto') }};
pid {{ nginx_pid_file | default('/run/nginx.pid') }};

events {
    worker_connections {{ nginx_worker_connections | default(1024) }};
    {% if nginx_use_epoll | default(true) %}
    use epoll;
    {% endif %}
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    {% if nginx_gzip_enabled | default(true) %}
    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_types
        text/plain
        text/css
        text/javascript
        application/json
        application/javascript;
    {% endif %}
    
    {% for site in nginx_sites | default([]) %}
    # Include site: {{ site.name }}
    include /etc/nginx/sites-enabled/{{ site.name }};
    {% endfor %}
}
```

### templates/nginx/site.conf.j2:
```nginx
# {{ ansible_managed }}
# Site configuration for {{ site_name }}

server {
    listen {{ site_port | default(80) }};
    server_name {{ site_server_name }};
    
    {% if site_ssl | default(false) %}
    listen {{ site_ssl_port | default(443) }} ssl http2;
    
    ssl_certificate {{ site_ssl_cert }};
    ssl_certificate_key {{ site_ssl_key }};
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    {% endif %}
    
    root {{ site_document_root }};
    index {{ site_index_files | join(' ') | default('index.html index.php') }};
    
    {% if site_php_enabled | default(false) %}
    # PHP Configuration
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass {{ php_fpm_socket | default('unix:/var/run/php/php8.1-fpm.sock') }};
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    {% endif %}
    
    {% if site_custom_locations is defined %}
    {% for location in site_custom_locations %}
    location {{ location.path }} {
        {% for directive in location.directives %}
        {{ directive }};
        {% endfor %}
    }
    {% endfor %}
    {% endif %}
    
    access_log {{ site_access_log | default('/var/log/nginx/' + site_name + '_access.log') }};
    error_log {{ site_error_log | default('/var/log/nginx/' + site_name + '_error.log') }};
}
```

### templates/systemd/service.j2:
```ini
# {{ ansible_managed }}
[Unit]
Description={{ service_description }}
{% if service_dependencies is defined %}
{% for dep in service_dependencies %}
{{ dep.type | default('After') }}={{ dep.name }}
{% endfor %}
{% endif %}

[Service]
Type={{ service_type | default('simple') }}
User={{ service_user }}
Group={{ service_group | default(service_user) }}
WorkingDirectory={{ service_working_directory }}
ExecStart={{ service_exec_start }}
{% if service_exec_reload is defined %}
ExecReload={{ service_exec_reload }}
{% endif %}
{% if service_exec_stop is defined %}
ExecStop={{ service_exec_stop }}
{% endif %}

Restart={{ service_restart | default('always') }}
RestartSec={{ service_restart_sec | default(10) }}

{% if service_environment is defined %}
{% for env_var, env_value in service_environment.items() %}
Environment="{{ env_var }}={{ env_value }}"
{% endfor %}
{% endif %}

StandardOutput={{ service_stdout | default('journal') }}
StandardError={{ service_stderr | default('journal') }}

[Install]
WantedBy={{ service_wanted_by | default('multi-user.target') }}
```

### templates/scripts/backup.sh.j2:
```bash
#!/bin/bash
# {{ ansible_managed }}
# Backup script for {{ inventory_hostname }}

set -e

# Configuration
BACKUP_DIR="{{ backup_directory | default('/mnt/backup') }}"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="{{ backup_log_file | default('/var/log/backup.log') }}"
RETENTION_DAYS="{{ backup_retention_days | default(7) }}"

# Functions
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Start backup
log_message "Starting backup on {{ inventory_hostname }}"

{% if backup_mysql | default(false) %}
# MySQL Backup
log_message "Backing up MySQL databases"
mysqldump --all-databases > "$BACKUP_DIR/mysql_${DATE}.sql"
{% endif %}

{% if backup_files is defined %}
# File System Backup
{% for backup_path in backup_files %}
log_message "Backing up {{ backup_path }}"
tar czf "$BACKUP_DIR/{{ backup_path | basename }}_${DATE}.tar.gz" "{{ backup_path }}"
{% endfor %}
{% endif %}

{% if backup_docker | default(false) %}
# Docker Backup
log_message "Backing up Docker volumes"
docker run --rm -v /var/lib/docker/volumes:/source -v "$BACKUP_DIR":/backup \
    alpine tar czf "/backup/docker_volumes_${DATE}.tar.gz" -C /source .
{% endif %}

# Cleanup old backups
log_message "Cleaning up backups older than $RETENTION_DAYS days"
find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -delete

log_message "Backup completed successfully"
```

### templates/docker/docker-compose.yml.j2:
```yaml
# {{ ansible_managed }}
version: '{{ docker_compose_version | default("3.8") }}'

services:
{% for service_name, service_config in docker_services.items() %}
  {{ service_name }}:
    image: {{ service_config.image }}
    {% if service_config.container_name is defined %}
    container_name: {{ service_config.container_name }}
    {% endif %}
    {% if service_config.ports is defined %}
    ports:
    {% for port in service_config.ports %}
      - "{{ port }}"
    {% endfor %}
    {% endif %}
    {% if service_config.volumes is defined %}
    volumes:
    {% for volume in service_config.volumes %}
      - {{ volume }}
    {% endfor %}
    {% endif %}
    {% if service_config.environment is defined %}
    environment:
    {% for env_var, env_value in service_config.environment.items() %}
      {{ env_var }}: {{ env_value }}
    {% endfor %}
    {% endif %}
    {% if service_config.networks is defined %}
    networks:
    {% for network in service_config.networks %}
      - {{ network }}
    {% endfor %}
    {% endif %}
    {% if service_config.depends_on is defined %}
    depends_on:
    {% for dependency in service_config.depends_on %}
      - {{ dependency }}
    {% endfor %}
    {% endif %}
    restart: {{ service_config.restart | default('unless-stopped') }}

{% endfor %}

{% if docker_networks is defined %}
networks:
{% for network_name, network_config in docker_networks.items() %}
  {{ network_name }}:
    {% if network_config.driver is defined %}
    driver: {{ network_config.driver }}
    {% endif %}
    {% if network_config.ipam is defined %}
    ipam:
      config:
        - subnet: {{ network_config.ipam.subnet }}
    {% endif %}
{% endfor %}
{% endif %}

{% if docker_volumes is defined %}
volumes:
{% for volume_name, volume_config in docker_volumes.items() %}
  {{ volume_name }}:
    {% if volume_config.driver is defined %}
    driver: {{ volume_config.driver }}
    {% endif %}
    {% if volume_config.driver_opts is defined %}
    driver_opts:
    {% for opt_name, opt_value in volume_config.driver_opts.items() %}
      {{ opt_name }}: {{ opt_value }}
    {% endfor %}
    {% endif %}
{% endfor %}
{% endif %}
```

## Jinja2-Features:

### 1. Filter:
```jinja2
{{ variable | default('default_value') }}
{{ list_var | join(', ') }}
{{ string_var | upper }}
{{ number_var | round(2) }}
{{ dict_var | to_json }}
{{ path_var | basename }}
```

### 2. Tests:
```jinja2
{% if variable is defined %}
{% if list_var is iterable %}
{% if string_var is string %}
{% if number_var is number %}
```

### 3. Loops:
```jinja2
{% for item in items %}
{{ loop.index }}: {{ item }}
{% endfor %}

{% for key, value in dict.items() %}
{{ key }} = {{ value }}
{% endfor %}
```

### 4. Bedingungen:
```jinja2
{% if environment == 'production' %}
production settings
{% elif environment == 'staging' %}
staging settings
{% else %}
development settings
{% endif %}
```

## Best Practices:
- **ansible_managed**: Header in generierten Dateien
- **Default-Werte**: Immer `| default()` Filter verwenden
- **Einrückung**: Korrekte YAML/JSON-Einrückung beachten
- **Validierung**: Template-Ausgabe validieren
- **Kommentare**: Template-Logik dokumentieren
- **Whitespace**: `trim_blocks` und `lstrip_blocks` nutzen
- **Escaping**: Bei HTML/XML auf Escaping achten

## Template-Debugging:
```bash
# Template-Ausgabe testen
ansible hostname -m template -a "src=test.j2 dest=/tmp/test.conf" --check

# Mit Diff anzeigen
ansible-playbook playbooks/site.yml --check --diff

# Template-Variablen debuggen
ansible hostname -m debug -a "var=nginx_sites"
```

## Häufige Fehler:
- **Undefined Variables**: Immer `| default()` verwenden
- **Falsche Einrückung**: YAML-Syntax beachten
- **Loop-Variablen**: `loop.index` vs `loop.index0`
- **String-Concatenation**: `{{ var1 + var2 }}` statt `{{ var1 }}{{ var2 }}`
