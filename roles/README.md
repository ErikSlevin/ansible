# Roles Directory

## Zweck
Das `roles/` Verzeichnis enthält Ansible-Rollen - wiederverwendbare, strukturierte Sammlungen von Tasks, Variablen, Files und Templates.

## Was sind Rollen:
Rollen sind die höchste Abstraktionsebene in Ansible. Sie kapseln komplette Funktionalitäten in einer standardisierten Verzeichnisstruktur und fördern Wiederverwendbarkeit.

## Rollen-Struktur:
```
roles/
└── rolename/
    ├── tasks/
    │   └── main.yml        # Haupt-Tasks der Rolle
    ├── handlers/
    │   └── main.yml        # Event-Handler
    ├── templates/
    │   └── config.j2       # Jinja2-Templates
    ├── files/
    │   └── script.sh       # Statische Dateien
    ├── vars/
    │   └── main.yml        # Interne Variablen
    ├── defaults/
    │   └── main.yml        # Standard-Variablen
    ├── meta/
    │   └── main.yml        # Rollen-Metadaten
    └── README.md           # Rollen-Dokumentation
```

## Rollen-Kategorien:

### 1. System-Rollen:
- **common** - Basis-System-Konfiguration
- **security** - System-Härtung
- **monitoring** - Monitoring-Agents
- **backup** - Backup-Lösungen

### 2. Service-Rollen:
- **nginx** - Webserver-Konfiguration
- **docker** - Container-Platform
- **mysql** - Datenbank-Server
- **redis** - In-Memory-Datenbank

### 3. Application-Rollen:
- **webapp** - Web-Anwendung
- **api** - API-Server
- **frontend** - Frontend-Deployment

## Rolle erstellen:
```bash
# Neue Rolle generieren
ansible-galaxy init roles/nginx

# Erstellt Struktur:
roles/nginx/
├── README.md
├── defaults/main.yml
├── files/
├── handlers/main.yml
├── meta/main.yml
├── tasks/main.yml
├── templates/
├── tests/
└── vars/main.yml
```

## Rollen in Playbooks verwenden:
```yaml
---
- hosts: webservers
  become: yes
  roles:
    - common
    - security
    - nginx
    - { role: webapp, app_version: "1.2.3" }
```

## Rollen-Beispiel (nginx):

### tasks/main.yml:
```yaml
---
- name: Install nginx
  apt:
    name: nginx
    state: present

- name: Start nginx
  service:
    name: nginx
    state: started
    enabled: yes
  notify: restart nginx
```

### handlers/main.yml:
```yaml
---
- name: restart nginx
  service:
    name: nginx
    state: restarted
```

### defaults/main.yml:
```yaml
---
nginx_port: 80
nginx_user: www-data
nginx_worker_processes: auto
```

### templates/nginx.conf.j2:
```nginx
user {{ nginx_user }};
worker_processes {{ nginx_worker_processes }};

http {
    server {
        listen {{ nginx_port }};
        # ... weitere Konfiguration
    }
}
```

## Rollen-Abhängigkeiten:
```yaml
# meta/main.yml
dependencies:
  - role: common
  - role: security
    become: yes
```

## Ansible Galaxy:
```bash
# Rollen aus Galaxy installieren
ansible-galaxy install geerlingguy.nginx

# Eigene Rollen veröffentlichen
ansible-galaxy import username repo-name

# Requirements file verwenden
ansible-galaxy install -r requirements.yml
```

### requirements.yml:
```yaml
---
# Aus Galaxy
- name: geerlingguy.docker
  version: "4.1.0"

# Aus Git
- src: https://github.com/username/ansible-role-custom
  name: custom-role
  version: main
```

## Best Practices:
- Eine Funktion pro Rolle
- Aussagekräftige defaults definieren
- Dokumentation in README.md
- Tests für Rollen schreiben
- Versionierung verwenden
- OS-Kompatibilität beachten
- Idempotenz sicherstellen
- Variablen-Namenskonvention: `rolename_variable`

## Testen von Rollen:
```bash
# Mit Molecule (erweitert)
molecule init role myrole
molecule test

# Einfacher Test
ansible-playbook tests/test.yml --connection=local
```

## Galaxy vs. Eigene Rollen:
- **Galaxy-Rollen**: Bewährte, getestete Community-Rollen
- **Eigene Rollen**: Spezifische Anforderungen, vollständige Kontrolle
- **Hybrid**: Galaxy als Basis, Anpassungen in eigenen Rollen
