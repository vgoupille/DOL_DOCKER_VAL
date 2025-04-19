#!/usr/bin/env bash

# Get Miniconda version from argument
MINICONDA_VERSION=$1

# Detect CPU architecture
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-aarch64.sh"
else
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh"
fi

# Download and install Miniconda
wget $MINICONDA_URL -O ~/miniconda.sh
bash ~/miniconda.sh -b -p /opt/conda
rm ~/miniconda.sh

# Initialize conda
/opt/conda/bin/conda init bash
echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

# Add conda to PATH
export PATH=/opt/conda/bin:$PATH 