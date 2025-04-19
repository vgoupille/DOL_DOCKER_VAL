#!/usr/bin/env bash

# Create and activate the environment
conda env create -f env_radian.yml
echo "conda activate env_radian" >> ~/.bashrc

# Verify installation
conda activate env_radian
python --version
radian --version 