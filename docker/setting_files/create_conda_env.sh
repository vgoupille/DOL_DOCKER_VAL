#!/usr/bin/env bash

# Create and activate the environment
conda env create -f renv1.yml
echo "conda activate renv1" >> ~/.bashrc

# Verify installation
conda activate renv1
python --version
radian --version 