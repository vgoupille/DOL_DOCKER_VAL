#!/bin/bash

# Install JupyterLab and create environment
conda install -c conda-forge jupyterlab && \
conda env create -f /pkgs/env_1.yml

# Configure kernels for Jupyter
R -e "IRkernel::installspec(user = FALSE, displayname = paste0('my_env_R ', Sys.getenv('R_VERSION')))" && \
conda run -n env_1 python -m ipykernel install --user --name=env_1 --display-name="Python (env_1)"

# Configure Jupyter settings
mkdir -p ~/.jupyter/lab/user-settings/@jupyterlab/notebook-extension
cat > ~/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings << EOL
{
    "codeCellConfig": {
        "lineNumbers": true,
        "autoClosingBrackets": true,
        "tabSize": 4
    }
}
EOL

