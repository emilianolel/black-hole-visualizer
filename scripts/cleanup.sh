#!/bin/bash
# scripts/cleanup.sh — Global Shutdown and Environment Cleanup.

# Move to project root
cd "$(dirname "$0")/.." || exit

echo "----------------------------------------------------"
echo "🌌 Schwarzschild Project: Global Cleanup"
echo "----------------------------------------------------"

# 1. Stop active services
if [ -f "scripts/manage.sh" ]; then
    ./scripts/manage.sh stop
fi

# 2. Cleanup local build artifacts
echo "🧹 Removing Python artifacts (__pycache__)..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null

echo "🧹 Removing environment directories (venv, node_modules)..."
rm -rf venv/
rm -rf frontend/node_modules/
rm -f scripts/*.log
rm -f scripts/*.pid

# 3. Optional: Infrastructure Destruction
read -p "⚠️  Do you want to destroy GCP Infrastructure (Terraform)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🏗️  Decommissioning Cloud Resources..."
    cd terraform/environments/dev || exit
    terraform destroy -auto-approve
    cd - > /dev/null
else
    echo "✅ Cloud Infrastructure PRESERVED."
fi

echo "----------------------------------------------------"
echo "✨ Cleanup Complete. Project is now in 'Cold Storage'."
echo "----------------------------------------------------"
