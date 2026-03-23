#!/bin/bash
# connect-jupyter.sh — Manages an SSH tunnel to a Dataproc Jupyter server.

# Default Configuration
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
REGION="northamerica-northeast2"
LOCAL_PORT=8888
REMOTE_PORT=8123
PID_FILE="/tmp/dataproc-jupyter-tunnel.pid"

usage() {
    echo "Usage: $0 [dev|prod] [--stop]"
    echo "Options:"
    echo "  dev/prod  Select the environment (defaults to dev)"
    echo "  --stop    Stop the active SSH tunnel"
    exit 1
}

stop_tunnel() {
    # 1. Try stopping by PID file
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null; then
            echo "Stopping SSH tunnel (PID: $PID)..."
            kill "$PID" 2>/dev/null
        fi
        rm "$PID_FILE"
    fi

    # 2. Safety check: ensure no residual process is listening on the port
    RESIDUAL_PID=$(lsof -t -i :$LOCAL_PORT 2>/dev/null)
    if [ ! -z "$RESIDUAL_PID" ]; then
        echo "Cleaning up residual process on port $LOCAL_PORT (PID: $RESIDUAL_PID)..."
        kill -9 "$RESIDUAL_PID" 2>/dev/null
    fi

    echo "✅ Tunnel stopped and port $LOCAL_PORT is free."
    exit 0
}

# Check for --stop flag first
if [[ "$1" == "--stop" || "$2" == "--stop" ]]; then
    stop_tunnel
fi

# Environment Selection
ENV=${1:-dev}
if [[ "$ENV" != "dev" && "$ENV" != "prod" ]]; then
    usage
fi

CLUSTER_NAME="${ENV}-dataproc-cluster"

echo "----------------------------------------------------"
echo "Connecting to environment: $ENV"
echo "Cluster: $CLUSTER_NAME"
echo "----------------------------------------------------"

# 1. Discover the Master Node
echo "Searching for Master Node..."
# Trying with labels first (standard), then falling back to name-based search
MASTER_NODE=$(gcloud compute instances list \
    --filter="labels.goog-dataproc-cluster-name=$CLUSTER_NAME AND (labels.goog-dataproc-cluster-role=MASTER OR name ~ .*-m$)" \
    --format="value(name)" --limit=1)

if [ -z "$MASTER_NODE" ]; then
    # Final fallback: search by name pattern only
    MASTER_NODE=$(gcloud compute instances list \
        --filter="name ~ ^$CLUSTER_NAME-m" \
        --format="value(name)" --limit=1)
fi

if [ -z "$MASTER_NODE" ]; then
    echo "Error: Master Node not found for cluster $CLUSTER_NAME"
    echo "Please ensure the cluster is RUNNING in project $PROJECT_ID"
    exit 1
fi
echo "Found Master: $MASTER_NODE"

# 2. Pre-flight: Sync SSH Keys
# This step automates the manual "SSH button" click in the console by 
# explicitly pushing your public key to your GCP OS Login profile.
echo "Synchronizing SSH keys with GCP OS Login (Pre-flight)..."
if [ ! -f "$HOME/.ssh/google_compute_engine.pub" ]; then
    echo "Generating new Google Compute Engine SSH keys..."
    ssh-keygen -t rsa -f "$HOME/.ssh/google_compute_engine" -C "$USER" -N ""
fi
gcloud compute os-login ssh-keys add --key-file="$HOME/.ssh/google_compute_engine.pub" --ttl=1d --quiet 2>/dev/null
echo "Keys synchronized."

# 3. Start SSH Tunnel
echo "Establishing SSH tunnel on port $LOCAL_PORT..."
gcloud compute ssh "$MASTER_NODE" --project "$PROJECT_ID" --tunnel-through-iap -- -L "$LOCAL_PORT:localhost:$REMOTE_PORT" -N -f
echo $! > "$PID_FILE"

# 3. Retrieve Security Token
echo "Retrieving Jupyter Token (this may take a moment)..."
# We try to get the active token from the internal docker container
TOKEN_URL=$(gcloud compute ssh "$MASTER_NODE" --project "$PROJECT_ID" --tunnel-through-iap \
    --command "sudo docker exec dataproc-jupyter-notebook jupyter server list" 2>/dev/null | grep -o 'http://localhost:[0-9]*/?token=[a-z0-9]*' | head -n 1)

if [ -z "$TOKEN_URL" ]; then
    echo "Warning: Could not extract token automatically."
    echo "Try opening: http://localhost:$LOCAL_PORT"
else
    # Replace the container port (8123) with our local tunnel port (8888) in the output string
    FINAL_URL=$(echo "$TOKEN_URL" | sed "s/:[0-9]*/:$LOCAL_PORT/")
    echo "----------------------------------------------------"
    echo "SUCCESS: Connection established!"
    echo "Open the URL below in your browser or VS Code:"
    echo ""
    echo "$FINAL_URL"
    echo "----------------------------------------------------"
fi

echo "To stop the tunnel later, run: $0 --stop"
