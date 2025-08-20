# Homelab Ansible Infrastructure

Ansible-Konfiguration für mein Homelab mit Proxmox VE.

## Struktur

```
├── ansible.cfg          # Ansible-Konfiguration
├── inventory/           # Inventar-Dateien
│   └── hosts.yml       # Haupt-Inventar
├── playbooks/          # Ansible-Playbooks
│   └── site.yml       # Haupt-Playbook
├── roles/              # Ansible-Rollen
├── group_vars/         # Gruppen-Variablen
├── host_vars/          # Host-Variablen
├── files/              # Statische Dateien
└── templates/          # Jinja2-Templates
```

## Verwendung

```bash
# Alle Hosts prüfen
ansible all -m ping

# Playbook ausführen
ansible-playbook playbooks/site.yml

# Nur bestimmte Hosts
ansible-playbook playbooks/site.yml --limit production

# Trockenlauf (Check-Modus)
ansible-playbook playbooks/site.yml --check

# Mit Verbose-Output
ansible-playbook playbooks/site.yml -v
```

## SSH-Keys

SSH-Keys für Ziel-Hosts müssen separat eingerichtet werden.

```bash
# SSH-Key für neuen Host kopieren
ssh-copy-id -i ~/.ssh/homelab_key.pub -p 62222 user@hostname

# Verbindung testen
ansible hostname -m ping
```

## Inventar-Gruppen

- **proxmox**: Proxmox VE Hosts
- **management**: Management-VMs (VLAN 10)
- **production**: Produktions-VMs (VLAN 20) 
- **dmz**: DMZ-VMs (VLAN 30)

## Sync-Workflow

```bash
# Neueste Änderungen vom Repo holen
~/bin/ansible-pull.sh

# Änderungen zum Repo pushen
~/bin/ansible-push.sh

# Schnell-Aliase
apull    # = ansible-pull.sh
apush    # = ansible-push.sh
acd      # = cd ~/ansible-infrastructure
aping    # = ansible all -m ping
```

## Playbook-Beispiele

### System-Update für alle Hosts
```bash
ansible-playbook playbooks/site.yml --tags update
```

### Nur Proxmox-Host konfigurieren
```bash
ansible-playbook playbooks/site.yml --limit proxmox
```

### Sicherheits-Hardening
```bash
ansible-playbook playbooks/security.yml
```

## Erweiterte Nutzung

### Ansible Vault für Secrets
```bash
# Vault-Datei erstellen
ansible-vault create group_vars/all/vault.yml

# Vault bearbeiten
ansible-vault edit group_vars/all/vault.yml

# Playbook mit Vault ausführen
ansible-playbook playbooks/site.yml --ask-vault-pass
```

### Custom Rollen entwickeln
```bash
# Neue Rolle erstellen
ansible-galaxy init roles/meine-rolle

# Rolle in Playbook verwenden
- hosts: all
  roles:
    - meine-rolle
```

## Troubleshooting

### Häufige Probleme

**SSH-Verbindung fehlgeschlagen:**
```bash
# Host-Keys zurücksetzen
ssh-keygen -R hostname

# Verbindung mit Debug testen
ansible hostname -m ping -vvv
```

**Sudo-Berechtigungen:**
```bash
# Mit Passwort-Prompt
ansible-playbook playbooks/site.yml --ask-become-pass

# Sudo-Berechtigung testen
ansible all -m shell -a "whoami" --become
```

## Nützliche Ansible-Module

- **apt**: Paket-Management für Debian/Ubuntu
- **systemd**: Service-Management
- **copy**: Dateien kopieren
- **template**: Jinja2-Templates verarbeiten
- **user**: Benutzer-Management
- **cron**: Cron-Jobs verwalten
- **ufw**: Firewall-Regeln

## Links

- [Ansible Dokumentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Galaxy](https://galaxy.ansible.com/) - Community Rollen
