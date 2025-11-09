#!/bin/bash

REPO_URL="https://github.com/Chuluet/Taller-EC2.git"
PROJECT_DIR="/home/ubuntu/taller-ec2"
ENV_NAME="fastapi_env"
CONDA_PATH="/home/ubuntu/miniconda3"

sudo apt update -y && sudo apt upgrade -y
sudo apt install -y git wget curl unzip

if [ ! -d "$CONDA_PATH" ]; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    bash ~/miniconda.sh -b -p $CONDA_PATH
    eval "$($CONDA_PATH/bin/conda shell.bash hook)"
    conda init
else
    eval "$($CONDA_PATH/bin/conda shell.bash hook)"
fi

$CONDA_PATH/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
$CONDA_PATH/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true

if [ ! -d "$PROJECT_DIR" ]; then
    git clone $REPO_URL $PROJECT_DIR
else
    cd $PROJECT_DIR && git pull
fi

cd $PROJECT_DIR

if ! $CONDA_PATH/bin/conda env list | grep -q "$ENV_NAME"; then
    $CONDA_PATH/bin/conda create -n $ENV_NAME python=3.10 -y
fi

$CONDA_PATH/bin/conda run -n $ENV_NAME pip install --upgrade pip
$CONDA_PATH/bin/conda run -n $ENV_NAME pip install -r requirements.txt

if [ -f "$PROJECT_DIR/fastapi.srv" ]; then
    sudo cp $PROJECT_DIR/fastapi.srv /etc/systemd/system/fastapi.service
fi

sudo systemctl daemon-reload
sudo systemctl enable fastapi
sudo systemctl restart fastapi
