#!/bin/bash
# Move to the directory where this script is located
cd "$(dirname "$0")" || exit

PID_FILE="vite.pid"
VITE_DIR="../../frontend"

start() {
    if [ -f "$PID_FILE" ]; then
        echo "⚠️  Frontend is already running (PID: $(cat $PID_FILE))."
        return
    fi

    echo "🚀 Starting Black Hole Visualizer Frontend..."
    cd "$VITE_DIR" || exit
    npm run dev -- --host > ../scripts/frontend/vite.log 2>&1 &
    NEW_PID=$!
    echo $NEW_PID > "../scripts/frontend/$PID_FILE"
    cd - > /dev/null
    echo "✅ Frontend started with PID: $NEW_PID"
    echo "📡 URL: http://localhost:5173"
}

stop() {
    if [ ! -f "$PID_FILE" ]; then
        echo "❌ No running frontend found (missing $PID_FILE)."
        return
    fi

    TARGET_PID=$(cat "$PID_FILE")
    echo "🛑 Stopping Frontend (PID: $TARGET_PID)..."
    kill "$TARGET_PID"
    rm "$PID_FILE"
    echo "✅ Frontend stopped."
}

status() {
    if [ -f "$PID_FILE" ]; then
        TARGET_PID=$(cat "$PID_FILE")
        if ps -p "$TARGET_PID" > /dev/null; then
            echo "🟢 Frontend is RUNNING (PID: $TARGET_PID)."
            return
        fi
        echo "🔴 PID file exists but process is dead."
        rm "$PID_FILE"
        return
    fi
    echo "⚪ Frontend is NOT running."
}

case "$1" in
    start) start ;;
    stop) stop ;;
    status) status ;;
    *) echo "Usage: $0 {start|stop|status}" ;;
esac
