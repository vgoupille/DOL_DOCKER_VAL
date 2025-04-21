#!/bin/bash

# Start JupyterLab in the background with VS Code specific settings
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root \
    --NotebookApp.token='' \
    --NotebookApp.password='' \
    --NotebookApp.allow_origin='*' \
    --NotebookApp.disable_check_xsrf=True \
    --ServerApp.allow_origin='*' \
    --ServerApp.disable_check_xsrf=True &

# Keep the container running
tail -f /dev/null 