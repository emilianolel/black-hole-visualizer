#!/bin/bash
# dev.sh — Runs the React/Vite development server.

cd frontend

# 1. Install if node_modules missing
if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install
fi

# 2. Run Vite
echo "----------------------------------------------------"
echo "🚀 Starting Black Hole Visualizer Frontend (DEV)"
echo "URL: http://localhost:5173"
echo "----------------------------------------------------"

npm run dev -- --host
