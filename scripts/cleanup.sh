#!/bin/bash
# cleanup.sh — Global Shutdown and Environment Decommissioning Utility.
#
# This script stops all active services, removes local build artifacts,
# clears virtual environments, and optionally destroys cloud infrastructure.
#
# Usage: ./scripts/cleanup.sh

set -euo pipefail

# --- Configuration & Constants ---
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Move to project root context
cd "${PROJECT_ROOT}"

function perform_cleanup() {
    echo "----------------------------------------------------"
    echo "🌌 Schwarzschild Project: Global Cleanup"
    echo "----------------------------------------------------"

    # 1. Stop active services using the central manager
    if [[ -x "scripts/manage.sh" ]]; then
        echo "🛑 Requesting service shutdown..."
        ./scripts/manage.sh stop
    fi

    # 2. Cleanup local build artifacts
    echo "🧹 Removing Python artifacts (__pycache__)..."
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

    echo "🧹 Removing environment directories (venv, node_modules)..."
    rm -rf venv/
    rm -rf frontend/node_modules/
    rm -f scripts/*.log
    rm -f scripts/*.pid

    # 3. Optional: Infrastructure Destruction
    # Using /dev/tty to ensure read works even if the script is piped
    local reply
    read -p "⚠️  Do you want to destroy ALL GCP Infrastructure (Terraform)? [y/N] " -n 1 -r < /dev/tty
    echo
    if [[ "${REPLY:-}" =~ ^[Yy]$ ]]; then
        echo "🏗️  Decommissioning Cloud Resources..."
        (
            cd terraform/environments/dev
            terraform destroy -auto-approve
        )
    else
        echo "✅ Cloud Infrastructure PRESERVED."
    fi

    echo "----------------------------------------------------"
    echo "✨ Cleanup Complete. Project is now in 'Cold Storage'."
    echo "----------------------------------------------------"
}

# --- Main ---
perform_cleanup
