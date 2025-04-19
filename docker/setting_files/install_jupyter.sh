#!/bin/bash

# Install JupyterLab and create environment
conda install -c conda-forge jupyterlab && \
conda env create -f docker/setting_files/env_1.yml && \
conda run -n env_1 python -m ipykernel install --user --name=env_1 --display-name="Python (env_1)" 