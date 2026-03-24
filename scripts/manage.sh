#!/bin/bash
# scripts/manage.sh — Unified Lifecycle Manager for Backend (FastAPI) and Frontend (Vite).

# Move to project root
cd "$(dirname "$0")/.." || exit

API_PID="scripts/api.pid"
FE_PID="scripts/frontend.pid"

status() {
    echo "----------------------------------------------------"
    echo "📊 Application Status"
    echo "----------------------------------------------------"
    
    # Check Backend
    if [ -f "$API_PID" ] && ps -p $(cat "$API_PID") > /dev/null; then
        echo "🟢 Backend (FastAPI):  RUNNING  (PID: $(cat "$API_PID"))"
    else
        echo "🔴 Backend (FastAPI):  STOPPED"
        [ -f "$API_PID" ] && rm "$API_PID"
    fi

    # Check Frontend
    if [ -f "$FE_PID" ] && ps -p $(cat "$FE_PID") > /dev/null; then
        echo "🟢 Frontend (Vite):    RUNNING  (PID: $(cat "$FE_PID"))"
    else
        echo "🔴 Frontend (Vite):    STOPPED"
        [ -f "$FE_PID" ] && rm "$FE_PID"
    fi
    echo "----------------------------------------------------"
}

start() {
    # 1. Ensure Backend Environment
    if [ ! -d "venv" ]; then
        echo "🐍 Creating Python virtual environment..."
        python3 -m venv venv
        source venv/bin/activate
        pip install --upgrade pip
        pip install -r src/api/requirements.txt
    else
        source venv/bin/activate
    fi

    # 1. Start Backend
    if [ ! -f "$API_PID" ]; then
        echo "🚀 Starting Backend API..."
        export PYTHONPATH=$PYTHONPATH:.
        uvicorn src.api.main:app --host 0.0.0.0 --port 8000 > scripts/api.log 2>&1 &
        echo $! > "$API_PID"
        echo "✅ Backend launched (Log: scripts/api.log)"
    else
        echo "⚠️  Backend already running."
    fi

    # 2. Ensure Frontend Environment
    if [ ! -d "frontend/node_modules" ]; then
        echo "📦 Installing Frontend dependencies (NPM)..."
        cd frontend || exit
        npm install
        cd ..
    fi

    # 2. Start Frontend
    if [ ! -f "$FE_PID" ]; then
        echo "🚀 Starting Frontend Visualizer..."
        cd frontend || exit
        npm run dev -- --host > ../scripts/frontend.log 2>&1 &
        echo $! > "../$FE_PID"
        cd ..
        echo "✅ Frontend launched (Log: scripts/frontend.log)"
    else
        echo "⚠️  Frontend already running."
    fi

    echo "📡 Dashboard: http://localhost:5173"
    echo "📡 API Docs:  http://localhost:8000/docs"
}

stop() {
    echo "🛑 Stopping all services..."
    
    # 1. Kill Backend (PID + Port fallback)
    if [ -f "$API_PID" ]; then
        TARGET_PID=$(cat "$API_PID")
        pkill -P "$TARGET_PID" 2>/dev/null
        kill "$TARGET_PID" 2>/dev/null
        rm "$API_PID"
    fi
    # Force clear port 8000
    lsof -ti :8000 | xargs kill -9 2>/dev/null
    echo "✅ Backend stopped."

    # 2. Kill Frontend (PID + Port fallback)
    if [ -f "$FE_PID" ]; then
        TARGET_PID=$(cat "$FE_PID")
        pkill -P "$TARGET_PID" 2>/dev/null
        kill "$TARGET_PID" 2>/dev/null
        rm "$FE_PID"
    fi
    # Force clear port 5173
    lsof -ti :5173 | xargs kill -9 2>/dev/null
    echo "✅ Frontend stopped."
}

case "$1" in
    start) start ;;
    stop) stop ;;
    status) status ;;
    restart) stop; sleep 2; start ;;
    *) echo "Usage: $0 {start|stop|status|restart}" ;;
esac
