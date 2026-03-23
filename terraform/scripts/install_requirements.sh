#!/usr/bin/env bash
###############################################################################
# install_requirements.sh — Instalador automático de dependencias (Terraform/gcloud)
# Soporta: macOS (Homebrew) y Linux (APT)
###############################################################################

set -euo pipefail

echo "🛠️  Verificando requerimientos del sistema..."
echo "----------------------------------------------------------"

# Detector de Sistema Operativo
OS_TYPE="$(uname -s)"
case "${OS_TYPE}" in
Darwin*) OS="mac" ;;
Linux*) OS="linux" ;;
*)
    echo "❌ OS no soportado automáticamente. Por favor instala Terraform y gcloud manualmente."
    exit 1
    ;;
esac

install_terraform() {
    echo "🏗️  Instalando Terraform..."
    if [[ "$OS" == "mac" ]]; then
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
    else
        sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
        wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt-get update && sudo apt-get install terraform
    fi
}

install_gcloud() {
    echo "☁️  Instalando Google Cloud SDK..."
    if [[ "$OS" == "mac" ]]; then
        brew install --cask google-cloud-sdk
    else
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/gpg.key | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        sudo apt-get update && sudo apt-get install google-cloud-sdk
    fi
}

# 1. Verificar Terraform
if ! command -v terraform &>/dev/null; then
    echo "⚠️  Terraform NO encontrado."
    install_terraform
else
    echo "✅ Terraform ya instalado: $(terraform version | head -n 1)"
fi

# 2. Verificar gcloud
if ! command -v gcloud &>/dev/null; then
    echo "⚠️  gcloud SDK NO encontrado."
    install_gcloud
else
    echo "✅ gcloud SDK ya instalado: $(gcloud --version | head -n 1)"
fi

echo "----------------------------------------------------------"
echo "🎉 ¡Todo listo! Verifica tu instalación con 'terraform -version' y 'gcloud --version'."
echo "💡 No olvides ejecutar 'gcloud auth login' después de la instalación."
