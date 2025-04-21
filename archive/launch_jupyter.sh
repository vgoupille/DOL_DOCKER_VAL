#!/bin/bash

# Kill any existing Jupyter processes
pkill -f jupyter

# Create logs directory if it doesn't exist
mkdir -p logs

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
    > logs/jupyter.log 2>&1 &

# Print the URL to access Jupyter
echo "Jupyter Lab is starting..."
echo "Access Jupyter Lab at: http://localhost:8888"
echo "Token: jupyter"
echo "Logs are available in logs/jupyter.log" 