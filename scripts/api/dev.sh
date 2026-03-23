#!/bin/bash
# dev.sh — Runs the FastAPI development server locally.

# 1. Check for Python environment
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate

# 2. Install requirements
echo "Checking dependencies..."
pip install -q -r src/api/requirements.txt

# 3. Run the API
echo "----------------------------------------------------"
echo "🚀 Starting Black Hole Visualizer API (DEV)"
echo "Docs: http://127.0.0.1:8000/docs"
echo "Health: http://127.0.0.1:8000/health"
echo "----------------------------------------------------"

# Ensure Google Application Credentials are set if running locally
# export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/key.json"

export PYTHONPATH=$PYTHONPATH:.
uvicorn src.api.main:app --reload --host 0.0.0.0 --port 8000
