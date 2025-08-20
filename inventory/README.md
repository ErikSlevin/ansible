# Inventory Directory

## Zweck
Das `inventory/` Verzeichnis enthält alle Inventar-Definitionen, die beschreiben, welche Hosts von Ansible verwaltet werden.

## Was gehört hier rein:
- **hosts.yml** - Haupt-Inventar-Datei mit allen Hosts und Gruppen
- **production.yml** - Produktions-spezifisches Inventar
- **staging.yml** - Test-/Staging-Umgebung
- **dynamic_inventory.py** - Dynamische Inventar-Skripte
- **static_hosts** - Statische Host-Listen im INI-Format

## Struktur:
```
inventory/
├── hosts.yml           # Haupt-Inventar (YAML)
├── production.yml      # Produktions-Hosts
├── staging.yml         # Test-Umgebung
└── group_vars/         # Verweis auf ../group_vars/
```

## Inventar-Format:
Ansible unterstützt sowohl YAML- als auch INI-Format. YAML wird empfohlen für komplexere Strukturen.

### YAML-Beispiel:
```yaml
all:
  children:
    homelab:
      children:
        proxmox:
          hosts:
            pve:
              ansible_host: 10.0.0.200
        vms:
          hosts:
            ansible-vm:
              ansible_host: 10.10.0.2
```

### INI-Beispiel:
```ini
[proxmox]
pve ansible_host=10.0.0.200

[vms]
ansible-vm ansible_host=10.10.0.2
```

## Host-Variablen:
- `ansible_host` - IP-Adresse oder Hostname
- `ansible_user` - SSH-Benutzer
- `ansible_port` - SSH-Port (Standard: 22)
- `ansible_ssh_private_key_file` - SSH-Key-Pfad

## Gruppen-Konzept:
- **all** - Alle Hosts (implizit)
- **ungrouped** - Hosts ohne Gruppe
- **Eigene Gruppen** - Logische Gruppierung (z.B. webservers, databases)

## Best Practices:
- Verwende sprechende Gruppennamen
- Strukturiere nach Funktion oder Umgebung
- Nutze `children` für Hierarchien
- Halte sensible Daten in group_vars/host_vars
- Teste Inventar mit: `ansible-inventory --list`
