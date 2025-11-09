#!/bin/bash
# =====================================================
# CONFIGURACIÓN AUTOMÁTICA DEL SERVICIO FASTAPI (Miniconda)
# =====================================================

# --- Variables ---
REPO_URL="https://github.com/Chuluet/Taller-EC2.git"
PROJECT_DIR="/home/ubuntu/taller-ec2"
ENV_NAME="fastapi_env"
CONDA_PATH="/home/ubuntu/miniconda3"

# --- Actualizar sistema ---
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y git wget curl unzip

# --- Instalar Miniconda si no está instalada ---
if [ ! -d "$CONDA_PATH" ]; then
    echo "🟡 Instalando Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    bash ~/miniconda.sh -b -p $CONDA_PATH
    eval "$($CONDA_PATH/bin/conda shell.bash hook)"
    conda init
else
    echo "✅ Miniconda ya instalada."
    eval "$($CONDA_PATH/bin/conda shell.bash hook)"
fi

# --- Aceptar términos de servicio (para evitar errores) ---
$CONDA_PATH/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
$CONDA_PATH/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true

# --- Clonar repositorio ---
if [ ! -d "$PROJECT_DIR" ]; then
    echo "🟡 Clonando repositorio..."
    git clone $REPO_URL $PROJECT_DIR
else
    echo "✅ Repositorio ya existe, actualizando..."
    cd $PROJECT_DIR && git pull
fi

cd $PROJECT_DIR

# --- Crear entorno conda ---
if ! $CONDA_PATH/bin/conda env list | grep -q "$ENV_NAME"; then
    echo "🟡 Creando entorno conda '$ENV_NAME'..."
    $CONDA_PATH/bin/conda create -n $ENV_NAME python=3.10 -y
else
    echo "✅ Entorno '$ENV_NAME' ya existe."
fi

# --- Instalar dependencias dentro del entorno ---
echo "🟡 Instalando dependencias en el entorno..."
$CONDA_PATH/bin/conda run -n $ENV_NAME pip install --upgrade pip
$CONDA_PATH/bin/conda run -n $ENV_NAME pip install -r requirements.txt

# --- Configurar servicio systemd ---
if [ -f "$PROJECT_DIR/fastapi.srv" ]; then
    echo "🟡 Configurando servicio FastAPI..."
    sudo cp $PROJECT_DIR/fastapi.srv /etc/systemd/system/fastapi.service
else
    echo "⚠️ Archivo 'fastapi.srv' no encontrado en $PROJECT_DIR"
    echo "Asegúrate de tenerlo en el repo antes de ejecutar este script."
fi

sudo systemctl daemon-reload
sudo systemctl enable fastapi
sudo systemctl restart fastapi

# --- Verificar estado del servicio ---
echo "✅ Instalación completa. Estado del servicio:"
sudo systemctl status fastapi --no-pager
