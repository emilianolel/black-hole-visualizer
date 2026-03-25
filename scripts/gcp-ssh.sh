#!/bin/bash

###############################################################################
# Script: gcp-ssh.sh
# Descripción: Conexión SSH simplificada a VMs de GCP con auto-descubrimiento.
# Uso: ./gcp-ssh.sh <VM_NAME>
###############################################################################

# --- Configuración de Colores y Emojis ---
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

LOG_INFO="[${GREEN}INFO${RESET}] 💡"
LOG_WARN="[${YELLOW}WARN${RESET}] ⚠️"
LOG_ERROR="[${RED}ERROR${RESET}] 🚀"
LOG_SUCCESS="[${GREEN}OK${RESET}] ✅"

# --- Funciones de Utilidad ---
function log_info()    { echo -e "${LOG_INFO} $1"; }
function log_warn()    { echo -e "${LOG_WARN} $1"; }
function log_error()   { echo -e "${LOG_ERROR} $1"; }
function log_success() { echo -e "${LOG_SUCCESS} $1"; }

# --- Validación de Argumentos ---
VM_NAME=$1

if [ -z "$VM_NAME" ]; then
    echo -e "${BOLD}Uso:${RESET} $0 <nombre-de-la-vm>"
    exit 1
fi

echo -e "${BOLD}${CYAN}------------------------------------------------------------${RESET}"
echo -e "${BOLD}${CYAN}   GCP SSH UTILITY — Búsqueda y Conexión Automática${RESET}"
echo -e "${BOLD}${CYAN}------------------------------------------------------------${RESET}"

# --- 1. Detección de Proyecto Actual ---
log_info "Detectando proyecto activo en gcloud..."
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    log_error "No se detectó un proyecto activo. Por favor ejecuta 'gcloud config set project <ID>'"
    exit 1
fi
log_success "Proyecto detectado: ${BOLD}$PROJECT_ID${RESET}"

# --- 2. Localización de la VM ---
log_info "Buscando VM '${BOLD}$VM_NAME${RESET}' en todas las zonas..."

# Buscamos la VM y obtenemos Nombre, Zona y Estado
VM_DATA=$(gcloud compute instances list --filter="name=($VM_NAME)" --format="csv[no-heading](name,zone,status)" --project="$PROJECT_ID" 2>/dev/null)

if [ -z "$VM_DATA" ]; then
    log_warn "No se encontró ninguna VM con el nombre '${BOLD}$VM_NAME${RESET}' en el proyecto."
    echo -e "\n${BOLD}Recursos disponibles en $PROJECT_ID:${RESET}"
    gcloud compute instances list --project="$PROJECT_ID" --format="table(name,zone,status)"
    exit 1
fi

# Extraer valores (csv format: name,zone,status)
IFS=',' read -r FOUND_NAME FOUND_ZONE FOUND_STATUS <<< "$VM_DATA"

log_success "Instancia encontrada en la zona: ${BOLD}$FOUND_ZONE${RESET} (Estado: $FOUND_STATUS)"

# --- 3. Validación de Conectividad ---
SSH_CMD="gcloud compute ssh $FOUND_NAME --zone=$FOUND_ZONE --project=$PROJECT_ID"

log_info "Verificando disponibilidad de red (Puerto 22)..."

# Verificar si nc está instalado
if ! command -v nc &> /dev/null; then
    log_warn "Netcat (nc) no está instalado. Saltando verificación de puerto."
else
    # Obtener IP externa
    VM_IP=$(gcloud compute instances describe "$FOUND_NAME" --zone="$FOUND_ZONE" --project="$PROJECT_ID" --format="get(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null)

    if [ -n "$VM_IP" ]; then
        log_info "IP Externa detectada: ${BOLD}$VM_IP${RESET}"
        # Intento de conexión al puerto 22 con timeout de 5s
        if nc -z -w 5 "$VM_IP" 22 2>/dev/null; then
            log_success "Puerto 22 (SSH) abierto y respondiendo."
        else
            log_warn "El puerto 22 no responde en $VM_IP. ¿Firewall bloqueando?"
            log_info "Intentando conexión por IAP (Cloud Identity-Aware Proxy) como alternativa..."
            SSH_CMD="$SSH_CMD --tunnel-through-iap"
        fi
    else
        log_warn "No se detectó IP externa. Se intentará conexión por IAP automáticamente."
        SSH_CMD="$SSH_CMD --tunnel-through-iap"
    fi
fi

# --- 4. Integración con TMUX ---
if [ -n "$TMUX" ]; then
    WINDOW_NAME="GCP VM: $VM_NAME"
    log_info "Sesión de Tmux detectada. Preparando ventana: ${BOLD}$WINDOW_NAME${RESET}"
    
    # Creamos la ventana y capturamos su ID para tener control total
    WINDOW_ID=$(tmux new-window -P -F "#{window_id}" -n "$WINDOW_NAME" "bash -c \"$SSH_CMD || { 
        echo -e '\n${RED}Error en la conexión SSH.${RESET}'; 
        echo -e '${YELLOW}Si ves un error 4003, asegúrate de tener una regla de firewall para IAP.${RESET}';
        echo -e '\nPresiona Enter para cerrar...'; read; exit 1; }\"")
    
    # Forzamos que el nombre NO cambie y lo reaplicamos por si acaso
    tmux set-window-option -t "$WINDOW_ID" allow-rename off
    tmux rename-window -t "$WINDOW_ID" "$WINDOW_NAME"
    
    log_success "Conexión iniciada en la ventana Tmux: ${BOLD}$WINDOW_ID${RESET}"
else
    log_info "Iniciando conexión SSH directa..."
    echo -e "${CYAN}------------------------------------------------------------${RESET}"
    eval "$SSH_CMD"
fi
