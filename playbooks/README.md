# Playbooks Directory

## Zweck
Das `playbooks/` Verzeichnis enthält Ansible-Playbooks - die Hauptorchestrator-Dateien, die definieren, welche Tasks auf welchen Hosts ausgeführt werden.

## Was sind Playbooks:
Playbooks sind YAML-Dateien, die eine oder mehrere "Plays" enthalten. Jedes Play definiert:
- **Ziel-Hosts** (hosts)
- **Auszuführende Tasks** (tasks)
- **Variablen** (vars)
- **Handler** (handlers)
- **Rollen** (roles)

## Was gehört hier rein:
- **site.yml** - Haupt-Playbook für komplette Infrastruktur
- **webservers.yml** - Spezifische Playbooks für Dienste
- **security.yml** - Sicherheits-spezifische Konfiguration
- **update.yml** - System-Update-Routinen
- **backup.yml** - Backup-Automatisierung
- **deploy.yml** - Deployment-Prozesse

## Playbook-Struktur:
```yaml
---
- name: Beschreibung des Plays
  hosts: zielgruppe
  become: yes          # Root-Rechte
  gather_facts: yes    # System-Informationen sammeln
  
  vars:
    variable: wert
  
  tasks:
    - name: Task-Beschreibung
      module:
        parameter: wert
  
  handlers:
    - name: Handler-Name
      service:
        name: service
        state: restarted
```

## Playbook-Typen:

### 1. Master-Playbooks:
- **site.yml** - Orchestriert komplette Infrastruktur
- **main.yml** - Alternative zu site.yml

### 2. Service-spezifische Playbooks:
- **webserver.yml** - Nginx/Apache Konfiguration
- **database.yml** - MySQL/PostgreSQL Setup
- **monitoring.yml** - Monitoring-Stack

### 3. Wartungs-Playbooks:
- **update.yml** - System-Updates
- **backup.yml** - Backup-Routinen
- **cleanup.yml** - System-Bereinigung

### 4. Deployment-Playbooks:
- **deploy-app.yml** - Anwendungs-Deployment
- **rollback.yml** - Rollback-Prozeduren

## Ausführung:
```bash
# Komplettes Playbook
ansible-playbook playbooks/site.yml

# Mit spezifischen Hosts
ansible-playbook playbooks/site.yml --limit webservers

# Mit Tags
ansible-playbook playbooks/site.yml --tags update

# Trockenlauf
ansible-playbook playbooks/site.yml --check

# Mit Variablen
ansible-playbook playbooks/site.yml -e "version=1.2.3"
```

## Best Practices:
- Ein Play pro logische Einheit
- Aussagekräftige Namen für Plays und Tasks
- Nutze Tags für selektive Ausführung
- Verwende `include_tasks` für Modularität
- Halte Playbooks fokussiert und klein
- Dokumentiere komplexe Logik
- Teste immer mit `--check` vor Produktions-Ausführung
