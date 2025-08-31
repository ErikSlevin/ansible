# Proxmox LXC Container Rolle

Diese Ansible-Rolle erstellt und konfiguriert automatisch LXC Container auf Proxmox VE.

## Features

- ✅ **Automatische Container-Erstellung** mit konfigurierbaren Parametern
- ✅ **Dynamische ID-Vergabe** oder manuelle ID-Spezifikation
- ✅ **System-Setup** (Locale, Zeitzone, Packages)
- ✅ **SSH-Härtung** mit personalisierten Bannern
- ✅ **UniFi-Integration** mit fertigen Registrierungs-Befehlen
- ✅ **VLAN-Unterstützung** für Netzwerk-Segmentierung
- ✅ **Fehlerbehandlung** mit automatischem Cleanup

## Schnellstart

### 1. Container mit Standard-Parametern erstellen
```bash
ansible-playbook playbooks/deploy-lxc.yml --ask-vault-pass \
  --extra-vars "ct_hostname=test-container"
```

### 2. Container mit spezifischen Parametern
```bash
ansible-playbook playbooks/deploy-lxc.yml --ask-vault-pass \
  --extra-vars "ct_hostname=webserver-01 ct_id=101 ct_vlan=30 ct_cores=4 ct_memory=4096"
```

### 3. Mit dem Deployment-Skript (empfohlen)
```bash
./deploy-lxc.sh -n webserver-01 -v 30 -c 4 -m 4096
```

## Parameter

| Parameter | Beschreibung | Standard | Beispiel |
|-----------|-------------|----------|----------|
| `ct_hostname` | Container-Hostname | `lxc-auto` | `webserver-01` |
| `ct_id` | Container-ID | Automatisch | `101` |
| `ct_vlan` | VLAN-Nummer | `20` | `30` |
| `ct_cores` | CPU-Kerne | `2` | `4` |
| `ct_memory` | RAM in MB | `2048` | `4096` |
| `ct_rootfs` | Root-Filesystem GB | `10` | `20` |
| `ct_ip` | IP-Adresse | `dhcp` | `10.20.0.100` |
| `ct_template` | LXC-Template | Debian 12 | `ubuntu-22.04` |
| `ct_tags` | Container-Tags | `lxc,managed` | `web,prod` |

## Verwendungsbeispiele

### Webserver-Container
```bash
./deploy-lxc.sh \
  --hostname webserver-01 \
  --vlan 30 \
  --cores 4 \
  --memory 4096 \
  --ip 10.30.0.100
```

### Database-Container
```bash
./deploy-lxc.sh \
  --hostname database-01 \
  --vlan 20 \
  --cores 6 \
  --memory 8192 \
  --ip 10.20.0.50
```

### Test-Container (temporär)
```bash
./deploy-lxc.sh \
  --hostname test-container \
  --cores 1 \
  --memory 1024 \
  --check  # Nur Simulation
```

## VLAN-Schema

| VLAN | Netzwerk | Verwendung |
|------|----------|------------|
| 10 | 10.10.0.0/24 | Management |
| 20 | 10.20.0.0/24 | Server/Production |
| 30 | 10.30.0.0/24 | DMZ/Web |

## UniFi-Integration

Nach dem Container-Deployment wird automatisch der fertige MongoDB-Befehl für die UniFi-Controller-Registrierung angezeigt:

```bash
# Beispiel-Output:
ssh pve 'mongo --port 27117 ace --eval "..."'
ssh pve 'service unifi restart'
```

## Debugging

### Debug-Modus aktivieren
```bash
ansible-playbook playbooks/deploy-lxc.yml --ask-vault-pass \
  --extra-vars "enable_debug=true ct_hostname=debug-container"
```

### Check-Modus (Simulation)
```bash
ansible-playbook playbooks/deploy-lxc.yml --check --ask-vault-pass \
  --extra-vars "ct_hostname=test-container"
```

### Container-Status prüfen
```bash
# Auf Proxmox-Host
pct list
pct status 101
pct config 101
```

## Troubleshooting

### Problem: Container-ID bereits vergeben
```
❌ FEHLER: Container mit ID 101 existiert bereits!
```

**Lösung:**
- Andere ID verwenden: `-e ct_id=102`
- Oder Container löschen: `pct destroy 101`

### Problem: Template nicht gefunden
```
❌ Template nicht verfügbar
```

**Lösung:**
- Templates prüfen: `pveam available`
- Template herunterladen: `pveam download local debian-12-standard_12.7-1_amd64.tar.zst`

### Problem: UniFi-Registrierung fehlschlägt
**Lösung:**
- UniFi-Controller erreichbar: `ping 10.0.0.254`
- MongoDB läuft: `service unifi status`
- Manuell registrieren mit angezeigtem Befehl

## Sicherheit

### SSH-Härtung
- ✅ Personalisierter SSH-Banner
- ✅ Verbindungszeiten limitiert (300s)
- ✅ Max. 3 Authentifizierungs-Versuche
- ✅ Max. 2 gleichzeitige Sessions

### Root-Passwort
- 🔐 Wird aus Ansible Vault geladen
- 🔐 Standard: `vault_default_root_password`
- 🔐 Pro Container: `-e ct_password=custom`

## Templates

### Verfügbare Templates
- `debian-12-standard_12.7-1_amd64.tar.zst` (Standard)
- `ubuntu-22.04-standard_22.04-1_amd64.tar.zst`
- `centos-stream-9-standard_9.0-1_amd64.tar.zst`

### Template herunterladen
```bash
# Auf Proxmox
pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
```

## Support

Bei Problemen:
1. Debug-Modus aktivieren (`--debug`)
2. Check-Modus testen (`--check`)
3. Ansible-Logs prüfen
4. Container manuell auf Proxmox prüfen
