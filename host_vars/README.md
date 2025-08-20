# Host Variables Directory

## Zweck
Das `host_vars/` Verzeichnis enthält host-spezifische Variablen, die nur für einzelne Hosts gelten.

## Was sind Host Variables:
Host Variables haben die höchste Priorität (außer extra vars) und überschreiben alle anderen Variablen-Quellen. Sie definieren einzigartige Konfigurationen für spezifische Hosts.

## Verzeichnisstruktur:
```
host_vars/
├── pve/                   # Proxmox Host (Hostname aus Inventar)
│   ├── main.yml          # Haupt-Konfiguration
│   ├── storage.yml       # Storage-spezifische Einstellungen
│   └── network.yml       # Netzwerk-Konfiguration
├── ansible-vm/           # Ansible Management VM
│   ├── main.yml
│   └── docker.yml
├── webserver-01.yml      # Einfache Datei für webserver-01
└── database-01.yml       # Einfache Datei für database-01
```

## Namenskonvention:
- **Dateiname = Hostname** aus dem Inventar
- **Exakter Match** erforderlich
- **Verzeichnis** für komplexe Host-Konfigurationen
- **Einzeldatei** für einfache Einstellungen

## Beispiel-Dateien:

### host_vars/pve/main.yml:
```yaml
---
# Proxmox Host-spezifische Konfiguration
host_role: "proxmox_host"
datacenter_name: "homelab"

# Proxmox-spezifische Einstellungen
pve_cluster_name: "homelab-cluster"
pve_storage_locations:
  - name: "local"
    type: "dir"
    path: "/var/lib/vz"
  - name: "backup"
    type: "dir"
    path: "/mnt/backup"

# Host-spezifische Netzwerk-Konfiguration
management_ip: "10.0.0.200"
backup_network: "10.0.0.0/24"

# Host-spezifische Benutzer
additional_users:
  - name: proxmox-admin
    groups: ["sudo", "www-data"]
    ssh_key: "ssh-ed25519 AAAA...specific-key"
```

### host_vars/ansible-vm/main.yml:
```yaml
---
# Ansible Management VM
host_role: "management"
vm_id: 100

# Container-spezifische Einstellungen
container_type: "lxc"
container_specs:
  cores: 2
  memory: 2048
  storage: 10

# Ansible-spezifische Konfiguration
ansible_collections:
  - community.general
  - ansible.posix
  - community.docker

ansible_python_packages:
  - requests
  - docker
  - kubernetes

# Git-Konfiguration für diesen Host
git_repositories:
  - repo: "git@github.com:username/ansible-infrastructure.git"
    dest: "/home/erik/ansible-infrastructure"
    version: "main"
```

### host_vars/webserver-01.yml:
```yaml
---
# Webserver-01 spezifische Konfiguration
host_role: "webserver"
server_id: 1

# Host-spezifische Nginx-Konfiguration
nginx_worker_processes: 4
nginx_sites:
  - name: "app1.homelab.local"
    server_name: "app1.homelab.local"
    document_root: "/var/www/app1"
    ssl: true
    ssl_cert: "/etc/ssl/certs/app1.crt"
    ssl_key: "/etc/ssl/private/app1.key"

# Host-spezifische SSL-Zertifikate
ssl_certificates:
  - name: "app1.homelab.local"
    country: "DE"
    state: "Berlin"
    city: "Berlin"
    organization: "Homelab"

# Backup-Konfiguration für diesen Host
backup_paths:
  - "/var/www"
  - "/etc/nginx"
  - "/etc/ssl"

backup_schedule: "0 2 * * *"  # Täglich um 2 Uhr
```

### host_vars/database-01.yml:
```yaml
---
# Database Server Host-spezifische Konfiguration
host_role: "database"

# MySQL-Konfiguration für diesen Host
mysql_config:
  max_connections: 200
  innodb_buffer_pool_size: "1G"
  innodb_log_file_size: "256M"
  query_cache_size: "128M"

# Host-spezifische Datenbanken
mysql_databases:
  - name: "webapp_prod"
    encoding: "utf8mb4"
    collation: "utf8mb4_unicode_ci"
  - name: "analytics"
    encoding: "utf8mb4"
    collation: "utf8mb4_unicode_ci"

# Host-spezifische Benutzer
mysql_users:
  - name: "webapp_user"
    password: "{{ vault_webapp_prod_password }}"
    priv: "webapp_prod.*:ALL"
    host: "10.20.0.%"
  - name: "analytics_user"
    password: "{{ vault_analytics_password }}"
    priv: "analytics.*:SELECT,INSERT,UPDATE"
    host: "10.20.0.%"

# Backup-Konfiguration
mysql_backup_schedule: "0 3 * * *"
mysql_backup_retention_days: 30
```

## Host-spezifische Vault-Variablen:
```yaml
# host_vars/database-01/vault.yml
---
vault_webapp_prod_password: "prod_secret_password"
vault_analytics_password: "analytics_secret"
vault_mysql_replication_password: "replication_secret"
```

## Verwendung in Playbooks:
```yaml
---
- name: Configure host-specific settings
  hosts: all
  become: yes
  
  tasks:
    - name: Display host role
      debug:
        msg: "Configuring {{ inventory_hostname }} as {{ host_role }}"
    
    - name: Install role-specific packages
      apt:
        name: "{{ packages[host_role] }}"
        state: present
      when: host_role is defined
    
    - name: Configure nginx sites
      template:
        src: nginx-site.j2
        dest: "/etc/nginx/sites-available/{{ item.name }}"
      loop: "{{ nginx_sites }}"
      when: nginx_sites is defined
      notify: restart nginx
```

## Best Practices:
- **Minimaler Einsatz**: Nur für wirklich host-spezifische Werte
- **Dokumentation**: Kommentare warum diese Variable host-spezifisch ist
- **Konsistente Struktur**: Gleiche Variablen-Namen über alle Hosts
- **Vault für Secrets**: Host-spezifische Passwörter verschlüsseln
- **Vererbung nutzen**: Überschreibe nur was nötig ist
- **Validierung**: Teste Variablen mit ansible-inventory

## Variable-Debugging:
```bash
# Host-spezifische Variablen anzeigen
ansible hostname -m debug -a "var=hostvars[inventory_hostname]"

# Spezifische Variable eines Hosts
ansible database-01 -m debug -a "var=mysql_config"

# Alle Variablen für einen Host
ansible-inventory --host database-01

# Variable-Auflösung testen
ansible-playbook playbooks/debug.yml --limit hostname
```

## Häufige Anwendungsfälle:
- **IP-Adressen**: Host-spezifische Network-Konfiguration
- **Hardware-Parameter**: CPU, RAM, Storage-Einstellungen
- **Service-Konfiguration**: Port-Nummern, Worker-Prozesse
- **SSL-Zertifikate**: Host-spezifische Zertifikate
- **Backup-Pfade**: Individuelle Backup-Strategien
- **Monitoring**: Host-spezifische Schwellwerte
- **Database-Konfiguration**: Performance-Tuning pro Host

## Template-Integration:
```jinja2
{# nginx-site.j2 Template #}
server {
    listen 80;
    server_name {{ item.server_name }};
    
    {% if item.ssl is defined and item.ssl %}
    listen 443 ssl;
    ssl_certificate {{ item.ssl_cert }};
    ssl_certificate_key {{ item.ssl_key }};
    {% endif %}
    
    root {{ item.document_root }};
    
    # Host-spezifische Worker-Prozesse
    {% if nginx_worker_processes is defined %}
    # Optimized for {{ nginx_worker_processes }} workers
    {% endif %}
}
```

## Inventory-Integration:
```yaml
# inventory/hosts.yml
all:
  children:
    databases:
      hosts:
        database-01:
          ansible_host: 10.20.0.10
          mysql_server_id: 1        # Host-spezifisch in Inventar
          mysql_role: master
        database-02:
          ansible_host: 10.20.0.11
          mysql_server_id: 2
          mysql_role: slave

# host_vars/database-01/main.yml nutzt dann:
mysql_replication_config:
  server_id: "{{ mysql_server_id }}"
  role: "{{ mysql_role }}"
```
