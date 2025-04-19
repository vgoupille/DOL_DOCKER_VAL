#!/bin/bash

# Install JupyterLab and create environment
conda install -c conda-forge jupyterlab && \
conda env create -f docker/setting_files/env_1.yml && \
conda run -n env_1 python -m ipykernel install --user --name=env_1 --display-name="Python (env_1)"

# Configure Jupyter settings
mkdir -p ~/.jupyter/lab/user-settings/@jupyterlab
cat > ~/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings << EOL
{
    "codeCellConfig": {
        "lineNumbers": true,
        "autoClosingBrackets": true,
        "tabSize": 4
    }
}
EOL

# Configure R kernel with dynamic version
R -e "IRkernel::installspec(user = FALSE, displayname = paste0('R ', Sys.getenv('R_VERSION')))"

# Set Jupyter memory limits
echo "c.MemoryManager.limit = 8 * 1024 * 1024 * 1024" >> ~/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.iopub_data_rate_limit = 10000000" >> ~/.jupyter/jupyter_notebook_config.py

# Configure JupyterLab to start automatically
echo "jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' &" >> ~/.bashrc
echo "sleep 2" >> ~/.bashrc
echo "echo 'JupyterLab is running at http://localhost:8888'" >> ~/.bashrc 