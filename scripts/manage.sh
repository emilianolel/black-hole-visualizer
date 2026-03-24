#!/bin/bash
# manage.sh — Unified Lifecycle Manager for Schwarzschild Black Hole Visualizer.
#
# This script manages the backend (FastAPI) and frontend (Vite) processes,
# handles automatic dependency resolution, and provides status monitoring.
#
# Usage: ./scripts/manage.sh {start|stop|status|restart}

set -euo pipefail

# --- Configuration & Constants ---
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly API_PID_FILE="${SCRIPT_DIR}/api.pid"
readonly FE_PID_FILE="${SCRIPT_DIR}/frontend.pid"
readonly API_LOG="${SCRIPT_DIR}/api.log"
readonly FE_LOG="${SCRIPT_DIR}/frontend.log"

# Move to project root context
cd "${PROJECT_ROOT}"

# --- Helper Functions ---

# Displays current status of both services.
function app_status() {
    echo "----------------------------------------------------"
    echo "📊 Application Status"
    echo "----------------------------------------------------"
    
    # Backend Status
    if [[ -f "${API_PID_FILE}" ]] && ps -p "$(cat "${API_PID_FILE}")" > /dev/null; then
        echo "🟢 Backend (FastAPI):  RUNNING  (PID: $(cat "${API_PID_FILE}"))"
    else
        echo "🔴 Backend (FastAPI):  STOPPED"
        [[ -f "${API_PID_FILE}" ]] && rm "${API_PID_FILE}"
    fi

    # Frontend Status
    if [[ -f "${FE_PID_FILE}" ]] && ps -p "$(cat "${FE_PID_FILE}")" > /dev/null; then
        echo "🟢 Frontend (Vite):    RUNNING  (PID: $(cat "${FE_PID_FILE}"))"
    else
        echo "🔴 Frontend (Vite):    STOPPED"
        [[ -f "${FE_PID_FILE}" ]] && rm "${FE_PID_FILE}"
    fi
    echo "----------------------------------------------------"
}

# Handles dependency checks and launches services.
function app_start() {
    # 1. Ensure Backend Environment (Binary Check)
    if [[ ! -f "venv/bin/uvicorn" ]]; then
        echo "🐍 Python environment incomplete. Installing dependencies..."
        python3 -m venv venv --clear
        source venv/bin/activate
        pip install --upgrade pip
        pip install -r src/api/requirements.txt
    else
        source venv/bin/activate
    fi

    # Start Backend
    if [[ ! -f "${API_PID_FILE}" ]]; then
        echo "🚀 Starting Backend API..."
        # Safely expand PYTHONPATH even if it's currently unbound
        export PYTHONPATH="${PROJECT_ROOT}:${PYTHONPATH:-}"
        ./venv/bin/uvicorn src.api.main:app --host 0.0.0.0 --port 8000 > "${API_LOG}" 2>&1 &
        echo $! > "${API_PID_FILE}"
        echo "✅ Backend launched (Log: scripts/api.log)"
    else
        echo "⚠️  Backend already running."
    fi

    # 2. Ensure Frontend Environment (Binary Check)
    if [[ ! -f "frontend/node_modules/.bin/vite" ]]; then
        echo "📦 Node environment incomplete. Installing dependencies..."
        (cd frontend && npm install)
    fi

    # Start Frontend
    if [[ ! -f "${FE_PID_FILE}" ]]; then
        echo "🚀 Starting Frontend Visualizer..."
        (
            cd frontend
            npm run dev -- --host > "${FE_LOG}" 2>&1 &
            echo $! > "${FE_PID_FILE}"
        )
        echo "✅ Frontend launched (Log: scripts/frontend.log)"
    else
        echo "⚠️  Frontend already running."
    fi

    echo "📡 Dashboard: http://localhost:5173"
    echo "📡 API Docs:  http://localhost:8000/docs"
}

# Stops all managed services and clears ports.
function app_stop() {
    echo "🛑 Stopping all services..."
    
    # 1. Stop Backend
    if [[ -f "${API_PID_FILE}" ]]; then
        local target_pid
        target_pid=$(cat "${API_PID_FILE}")
        pkill -P "${target_pid}" 2>/dev/null || true
        kill "${target_pid}" 2>/dev/null || true
        rm "${API_PID_FILE}"
    fi
    # Hard clear port 8000 (standard FastAPI port)
    lsof -ti :8000 | xargs kill -9 2>/dev/null || true
    echo "✅ Backend stopped."

    # 2. Stop Frontend
    if [[ -f "${FE_PID_FILE}" ]]; then
        local target_pid
        target_pid=$(cat "${FE_PID_FILE}")
        pkill -P "${target_pid}" 2>/dev/null || true
        kill "${target_pid}" 2>/dev/null || true
        rm "${FE_PID_FILE}"
    fi
    # Hard clear port 5173 (standard Vite port)
    lsof -ti :5173 | xargs kill -9 2>/dev/null || true
    echo "✅ Frontend stopped."
}

# --- Command Router ---

case "${1:-}" in
    start)   app_start ;;
    stop)    app_stop ;;
    status)  app_status ;;
    restart) app_stop; sleep 2; app_start ;;
    *)       echo "Usage: $0 {start|stop|status|restart}"; exit 1 ;;
esac
