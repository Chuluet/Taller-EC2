#!/bin/bash
# ===============================================
# CONFIGURACIÓN AUTOMÁTICA DEL SERVICIO FASTAPI
# ===============================================

# --- Variables de configuración ---
REPO_URL="https://github.com/Chuluet/Taller-EC2.git"
PROJECT_DIR="/home/ubuntu/taller-ec2"
ENV_NAME="fastapi_env"

# --- Actualizar sistema e instalar dependencias básicas ---
sudo apt update -y
sudo apt install -y git wget curl

# --- Instalar Miniconda (si no está instalado) ---
if [ ! -d "/home/ubuntu/miniconda3" ]; then
    echo "Instalando Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    bash ~/miniconda.sh -b -p $HOME/miniconda3
    eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
    conda init
else
    echo "Miniconda ya está instalada."
    eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
fi

# --- Clonar el repositorio (si no existe) ---
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Clonando repositorio..."
    git clone $REPO_URL $PROJECT_DIR
else
    echo "Repositorio ya existe. Actualizando..."
    cd $PROJECT_DIR && git pull
fi

cd $PROJECT_DIR

# --- Crear entorno conda ---
if ! conda env list | grep -q "$ENV_NAME"; then
    echo "Creando entorno conda..."
    conda create -n $ENV_NAME python=3.11 -y
else
    echo "Entorno conda ya existe."
fi

# --- Activar entorno y instalar dependencias ---
echo "Activando entorno..."
conda activate $ENV_NAME

echo "Instalando dependencias..."
pip install -r requirements.txt

# --- Configurar servicio systemd ---
echo "Configurando servicio FastAPI..."
sudo cp fastapi.srv /etc/systemd/system/fastapi.service
sudo systemctl daemon-reload
sudo systemctl enable fastapi
sudo systemctl restart fastapi

echo "✅ Configuración completa. El servicio está corriendo en el puerto 8000."
echo "Prueba con: curl -X POST http://<IP_PUBLICA>:8000/insert/"
