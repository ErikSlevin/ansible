# Group Variables Directory

## Zweck
Das `group_vars/` Verzeichnis enthält Variablen, die für bestimmte Host-Gruppen gelten.

## Was sind Group Variables:
Group Variables definieren Variablen für alle Hosts einer bestimmten Inventar-Gruppe. Sie überschreiben Rolle-Defaults, werden aber von Host-Variablen überschrieben.

## Verzeichnisstruktur:
```
group_vars/
├── all/                    # Variablen für ALLE Hosts
│   ├── common.yml         # Allgemeine Einstellungen
│   ├── users.yml          # Benutzer-Definitionen
│   └── vault.yml          # Verschlüsselte Secrets (Vault)
├── webservers/            # Variablen für webservers-Gruppe
│   ├── nginx.yml          # Nginx-Konfiguration
│   └── ssl.yml            # SSL-Einstellungen
├── databases.yml          # Einfache Datei für databases-Gruppe
└── production.yml         # Produktions-spezifische Variablen
```

## Datei-Namenskonventionen:
- **Dateiname = Gruppenname** aus dem Inventar
- **all.yml** oder **all/** für alle Hosts
- **Verzeichnis** für mehrere Dateien pro Gruppe
- **Einzeldatei** für einfache Konfigurationen

## Variable-Hierarchie (Priorität aufsteigend):
1. role defaults
2. inventory file or script group vars
3. inventory group_vars/all
4. playbook group_vars/all
5. inventory group_vars/*
6. playbook group_vars/*
7. inventory file or script host vars
8. inventory host_vars/*
9. playbook host_vars/*
10. host facts
11. registered vars
12. set_facts
13. play vars
14. play vars_prompt
15. play vars_files
16. role vars
17. block vars
18. task vars
19. include_vars
20. extra vars (command line -e)

## Beispiel-Dateien:

### group_vars/all/common.yml:
```yaml
---
# Allgemeine Variablen für alle Hosts
timezone: "Europe/Berlin"
ntp_servers:
  - "0.pool.ntp.org"
  - "1.pool.ntp.org"

admin_user: erik
admin_email: "admin@homelab.local"

# Package Listen
essential_packages:
  - curl
  - wget
  - git
  - vim
  - htop

security_packages:
  - fail2ban
  - ufw
  - chrony
```

### group_vars/webservers/nginx.yml:
```yaml
---
# Nginx-spezifische Variablen
nginx_port: 80
nginx_ssl_port: 443
nginx_user: www-data
nginx_worker_processes: auto
nginx_worker_connections: 1024

nginx_sites:
  - name: default
    server_name: localhost
    document_root: /var/www/html
```

### group_vars/databases.yml:
```yaml
---
# Datenbank-Konfiguration
mysql_root_password: "{{ vault_mysql_root_password }}"
mysql_databases:
  - name: webapp_db
    encoding: utf8mb4
    collation: utf8mb4_unicode_ci

mysql_users:
  - name: webapp_user
    password: "{{ vault_webapp_db_password }}"
    priv: "webapp_db.*:ALL"
```

## Ansible Vault für Secrets:
```bash
# Vault-Datei erstellen
ansible-vault create group_vars/all/vault.yml

# Vault bearbeiten
ansible-vault edit group_vars/all/vault.yml

# Vault-Inhalt anzeigen
ansible-vault view group_vars/all/vault.yml
```

### group_vars/all/vault.yml:
```yaml
---
# Verschlüsselte Secrets
vault_mysql_root_password: "super_secret_password"
vault_webapp_db_password: "another_secret"
vault_ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...key content...
  -----END OPENSSH PRIVATE KEY-----
```

## Variable-Referenzierung:
```yaml
# In Playbooks/Tasks verwenden
- name: Create database user
  mysql_user:
    name: "{{ mysql_users[0].name }}"
    password: "{{ mysql_users[0].password }}"
    priv: "{{ mysql_users[0].priv }}"

# Vault-Variablen referenzieren
mysql_root_password: "{{ vault_mysql_root_password }}"
```

## Best Practices:
- **Logische Gruppierung**: Ähnliche Variablen zusammenfassen
- **Sprechende Namen**: `webserver_port` statt `port`
- **Konsistente Benennung**: `service_name_setting`
- **Vault für Secrets**: Niemals Passwörter im Klartext
- **Dokumentation**: Kommentare für komplexe Variablen
- **Default-Werte**: Sinnvolle Standardwerte definieren
- **Environment-Trennung**: dev/staging/prod unterscheiden

## Debugging von Variablen:
```bash
# Alle Variablen eines Hosts anzeigen
ansible hostname -m debug -a "var=hostvars[inventory_hostname]"

# Spezifische Variable prüfen
ansible webservers -m debug -a "var=nginx_port"

# Alle Gruppen-Variablen
ansible-inventory --list --yaml
```

## Variable-Verschmelzung:
```yaml
# Liste erweitern (merge)
packages_base:
  - curl
  - wget

packages_additional:
  - nginx
  - mysql

all_packages: "{{ packages_base + packages_additional }}"

# Dictionary mergen
config_base:
  timeout: 30
  retries: 3

config_override:
  timeout: 60

final_config: "{{ config_base | combine(config_override) }}"
```
