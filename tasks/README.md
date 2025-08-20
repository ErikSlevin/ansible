# Tasks Directory

## Zweck
Das `tasks/` Verzeichnis enthält wiederverwendbare Task-Dateien, die in Playbooks und Rollen eingebunden werden können.

## Was sind Tasks:
Tasks sind die kleinste Ausführungseinheit in Ansible. Sie rufen Module auf und definieren den gewünschten Zustand des Systems.

## Was gehört hier rein:
- **system-update.yml** - Standard System-Update Tasks
- **security-hardening.yml** - Sicherheits-Konfiguration Tasks
- **user-management.yml** - Benutzer-Verwaltung Tasks
- **monitoring.yml** - System-Monitoring Tasks
- **docker.yml** - Docker-Installation und -Konfiguration
- **nginx.yml** - Nginx-spezifische Tasks
- **ssl-setup.yml** - SSL-Zertifikat Tasks

## Task-Struktur:
```yaml
---
- name: Beschreibende Task-Bezeichnung
  module_name:
    parameter1: wert1
    parameter2: wert2
  become: yes
  when: bedingung
  tags: 
    - tag1
    - tag2
  notify: handler_name
```

## Verwendung in Playbooks:
```yaml
# In einem Playbook einbinden
tasks:
  - name: Include security tasks
    include_tasks: ../tasks/security-hardening.yml
    tags: security

  - name: Include with variables
    include_tasks: ../tasks/user-management.yml
    vars:
      username: erik
      user_groups: ["sudo", "docker"]
```

## Task-Kategorien:

### 1. System-Tasks:
- **system-update.yml** - Paket-Updates, Kernel-Updates
- **timezone.yml** - Zeitzone-Konfiguration
- **hostname.yml** - Hostname-Einstellungen
- **mount.yml** - Dateisystem-Mounts

### 2. Security-Tasks:
- **security-hardening.yml** - System-Härtung
- **firewall.yml** - Firewall-Regeln
- **fail2ban.yml** - Intrusion Detection
- **ssh-hardening.yml** - SSH-Sicherheit

### 3. Service-Tasks:
- **docker.yml** - Docker Installation/Konfiguration
- **nginx.yml** - Webserver-Setup
- **database.yml** - Datenbank-Installation
- **backup.yml** - Backup-Konfiguration

### 4. User-Tasks:
- **user-management.yml** - Benutzer erstellen/verwalten
- **ssh-keys.yml** - SSH-Key Management
- **sudo-config.yml** - Sudo-Berechtigung

## Task-Features:

### Conditional Execution:
```yaml
- name: Task nur für Ubuntu
  apt:
    name: package
  when: ansible_distribution == "Ubuntu"
```

### Loops:
```yaml
- name: Multiple packages installieren
  apt:
    name: "{{ item }}"
  loop:
    - vim
    - git
    - curl
```

### Error Handling:
```yaml
- name: Task mit Fehlerbehandlung
  command: /bin/false
  ignore_errors: yes
  failed_when: false
```

### Tags:
```yaml
- name: Tagged task
  service:
    name: nginx
    state: started
  tags:
    - nginx
    - webserver
```

## Best Practices:
- Eine Aufgabe pro Task
- Beschreibende Namen verwenden
- `changed_when` für Commands definieren
- `when` Bedingungen für OS-spezifische Tasks
- Tags für selektive Ausführung
- `become` nur wenn Root-Rechte nötig
- Idempotenz sicherstellen
- Error-Handling implementieren

## Ausführung:
```bash
# Direkte Task-Ausführung (für Tests)
ansible-playbook -e "hosts=all" tasks/system-update.yml

# Mit spezifischen Variablen
ansible-playbook tasks/user-management.yml -e "username=testuser"
```
