#!/usr/bin/env bash

echo "Build the docker"

# Parameters
user_name="vgoupille"
image_label="Val_dev"
R_VERSION="4.4.0"
quarto_ver="1.5.47"
python_ver="3.10"
venv_name="r-env"
miniconda_ver="py310_23.11.0-2"

# Identify the CPU type (M1 vs Intel)
if [[ $(uname -m) ==  "aarch64" ]] ; then
  CPU="arm64"
elif [[ $(uname -m) ==  "arm64" ]] ; then
  CPU="arm64"
else
  CPU="amd64"
fi

# Setting the image name
tag="${CPU}.${R_VERSION}"
docker_file=Dockerfile.Val_dev
image_name=$user_name/$image_label:$tag

echo "Image name: $image_name"

# Build
docker build . \
  -f $docker_file --progress=plain \
  --build-arg PYTHON_VER=$python_ver \
  --build-arg R_VERSION=$R_VERSION \
  --build-arg QUARTO_VERSION=$quarto_ver \
  --build-arg VENV_NAME=$venv_name \
  --build-arg MINICONDA_VERSION=$miniconda_ver \
   -t $image_name

# Push
if [[ $? = 0 ]] ; then
echo "Pushing docker..."
docker push $image_name
else
echo "Docker build failed"
fi