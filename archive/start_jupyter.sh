#!/bin/bash

# Create logs directory if it doesn't exist
mkdir -p /root/logs

# Kill any existing Jupyter processes
pkill -f jupyter || true

# Launch Jupyter Lab with specific configurations
nohup jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.token='jupyter' \
    --NotebookApp.password='' \
    --NotebookApp.allow_origin='*' \
    --NotebookApp.base_url='/jupyter' \
    > /root/logs/jupyter.log 2>&1 &

# Wait for Jupyter to start
sleep 2

# Check if Jupyter is running
if pgrep -f jupyter > /dev/null; then
    echo "Jupyter Lab started successfully"
    echo "Access Jupyter Lab at: http://localhost:8888"
    echo "Token: jupyter"
    echo "Logs are available in /root/logs/jupyter.log"
else
    echo "Failed to start Jupyter Lab"
    echo "Check /root/logs/jupyter.log for details"
    exit 1
fi 