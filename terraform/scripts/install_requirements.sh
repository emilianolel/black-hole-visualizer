#!/usr/bin/env bash
###############################################################################
# install_requirements.sh — Automatic dependency installer (Terraform/gcloud)
# Supports: macOS (Homebrew) and Linux (APT)
###############################################################################

set -euo pipefail

echo "🛠️  Verifying system requirements..."
echo "----------------------------------------------------------"

# Detector de Sistema Operativo
OS_TYPE="$(uname -s)"
case "${OS_TYPE}" in
Darwin*) OS="mac" ;;
Linux*) OS="linux" ;;
*)
    echo "❌ OS not automatically supported. Please install Terraform and gcloud manually."
    exit 1
    ;;
esac

install_terraform() {
    echo "🏗️  Installing Terraform..."
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
    echo "☁️  Installing Google Cloud SDK..."
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
    echo "⚠️  Terraform NOT found."
    install_terraform
else
    echo "✅ Terraform already installed: $(terraform version | head -n 1)"
fi

# 2. Verificar gcloud
if ! command -v gcloud &>/dev/null; then
    echo "⚠️  gcloud SDK NOT found."
    install_gcloud
else
    echo "✅ gcloud SDK already installed: $(gcloud --version | head -n 1)"
fi

echo "----------------------------------------------------------"
echo "🎉 All set! Verify your installation with 'terraform -version' and 'gcloud --version'."
echo "💡 Don't forget to run 'gcloud auth login' after installation."
