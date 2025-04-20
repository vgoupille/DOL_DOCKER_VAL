#!/usr/bin/env bash

# Initialize conda
eval "$(conda shell.bash hook)"

# Create and activate the environment
conda env create -f pkgs/env_1.yml
echo "conda activate env_1" >> ~/.bashrc

# Verify installation
conda activate env_1
python --version