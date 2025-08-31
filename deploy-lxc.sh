#!/bin/bash
# LXC Container Deployment Skript
# Verwendung: ./deploy-lxc.sh [OPTIONEN]

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Standard-Werte
DEFAULT_HOSTNAME="test-container"
DEFAULT_ID=""
DEFAULT_VLAN="20"
DEFAULT_CORES="2"
DEFAULT_MEMORY="2048"
DEFAULT_TEMPLATE="synology:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"

# Funktionen
print_usage() {
    echo -e "${BLUE}LXC Container Deployment Script${NC}"
    echo ""
    echo "Verwendung: $0 [OPTIONEN]"
    echo ""
    echo "Optionen:"
    echo "  -n, --hostname NAME     Container-Hostname (default: $DEFAULT_HOSTNAME)"
    echo "  -i, --id ID            Container-ID (default: automatisch)"
    echo "  -v, --vlan VLAN        VLAN-Nummer (default: $DEFAULT_VLAN)"
    echo "  -c, --cores CORES      CPU-Kerne (default: $DEFAULT_CORES)"
    echo "  -m, --memory MB        RAM in MB (default: $DEFAULT_MEMORY)"
    echo "  -t, --template TPL     Template-Name (default: Debian 12)"
    echo "  --ip IP                Feste IP (default: DHCP)"
    echo "  --check                Nur Check-Modus (kein Deployment)"
    echo "  --debug                Debug-Ausgaben aktivieren"
    echo "  -h, --help             Diese Hilfe anzeigen"
    echo ""
    echo "Beispiele:"
    echo "  $0 -n webserver-01 -v 30 -c 4 -m 4096"
    echo "  $0 --hostname database --ip 10.20.0.100 --check"
    echo "  $0 -n test-vm --debug"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Parameter parsen
HOSTNAME="$DEFAULT_HOSTNAME"
CONTAINER_ID="$DEFAULT_ID"
VLAN="$DEFAULT_VLAN"
CORES="$DEFAULT_CORES"
MEMORY="$DEFAULT_MEMORY"
TEMPLATE="$DEFAULT_TEMPLATE"
IP="dhcp"
CHECK_MODE=""
DEBUG_MODE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--hostname)
            HOSTNAME="$2"
            shift 2
            ;;
        -i|--id)
            CONTAINER_ID="$2"
            shift 2
            ;;
        -v|--vlan)
            VLAN="$2"
            shift 2
            ;;
        -c|--cores)
            CORES="$2"
            shift 2
            ;;
        -m|--memory)
            MEMORY="$2"
            shift 2
            ;;
        -t|--template)
            TEMPLATE="$2"
            shift 2
            ;;
        --ip)
            IP="$2"
            shift 2
            ;;
        --check)
            CHECK_MODE="--check"
            shift
            ;;
        --debug)
            DEBUG_MODE="--extra-vars enable_debug=true"
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            print_error "Unbekannte Option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Validierungen
if [[ ! "$VLAN" =~ ^[0-9]+$ ]] || [[ "$VLAN" -lt 1 ]] || [[ "$VLAN" -gt 4094 ]]; then
    print_error "Ungültige VLAN-Nummer: $VLAN (1-4094 erlaubt)"
    exit 1
fi

if [[ ! "$CORES" =~ ^[0-9]+$ ]] || [[ "$CORES" -lt 1 ]] || [[ "$CORES" -gt 32 ]]; then
    print_error "Ungültige CPU-Kerne: $CORES (1-32 erlaubt)"
    exit 1
fi

if [[ ! "$MEMORY" =~ ^[0-9]+$ ]] || [[ "$MEMORY" -lt 512 ]]; then
    print_error "Ungültiger RAM: $MEMORY (mindestens 512 MB)"
    exit 1
fi

# Ansible-Verzeichnis prüfen
if [[ ! -f "ansible.cfg" ]] || [[ ! -d "playbooks" ]]; then
    print_error "Skript muss im Ansible-Root-Verzeichnis ausgeführt werden!"
    exit 1
fi

# Header anzeigen
clear
echo -e "${BLUE}"
echo "=================================="
echo "🚀 LXC CONTAINER DEPLOYMENT"
echo "=================================="
echo -e "${NC}"

print_info "Deployment-Parameter:"
echo "  Hostname: $HOSTNAME"
[[ -n "$CONTAINER_ID" ]] && echo "  Container-ID: $CONTAINER_ID" || echo "  Container-ID: automatisch"
echo "  VLAN: $VLAN"
echo "  CPU-Kerne: $CORES"
echo "  RAM: ${MEMORY}MB"
echo "  IP: $IP"
echo "  Template: $TEMPLATE"
[[ -n "$CHECK_MODE" ]] && echo "  Modus: Nur Überprüfung"

echo ""
read -p "Deployment starten? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Deployment abgebrochen."
    exit 0
fi

# Ansible-Playbook ausführen
print_info "Starte Ansible-Deployment..."

ANSIBLE_CMD="ansible-playbook playbooks/deploy-lxc.yml --ask-vault-pass"

# Extra-Variablen zusammenstellen
EXTRA_VARS="ct_hostname=$HOSTNAME ct_vlan=$VLAN ct_cores=$CORES ct_memory=$MEMORY ct_ip=$IP ct_template=$TEMPLATE"
[[ -n "$CONTAINER_ID" ]] && EXTRA_VARS="$EXTRA_VARS ct_id=$CONTAINER_ID"

ANSIBLE_CMD="$ANSIBLE_CMD --extra-vars \"$EXTRA_VARS\""
[[ -n "$CHECK_MODE" ]] && ANSIBLE_CMD="$ANSIBLE_CMD $CHECK_MODE"
[[ -n "$DEBUG_MODE" ]] && ANSIBLE_CMD="$ANSIBLE_CMD $DEBUG_MODE"

print_info "Führe aus: $ANSIBLE_CMD"
echo ""

# Ansible ausführen
if eval $ANSIBLE_CMD; then
    print_success "Container-Deployment erfolgreich abgeschlossen!"
else
    print_error "Deployment fehlgeschlagen!"
    exit 1
fi
