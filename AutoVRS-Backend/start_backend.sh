#!/bin/bash
# start_backend.sh - Script to start the AutoVRS Backend

echo "🚀 Starting AutoVRS Backend..."

# Activate virtual environment
source ../APPAutoVRS/autovrs-env/Scripts/activate

# Set Python path
export PYTHONPATH=$(pwd)

# Start the server
echo "📡 Backend will be available at: http://localhost:8000"
echo "📚 API Documentation: http://localhost:8000/docs"
echo "🏠 System Status API: http://localhost:8000/api/system/status"
echo ""

python app/main.py
