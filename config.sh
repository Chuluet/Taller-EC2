#!/bin/bash
# ===============================================
# CONFIGURACIÓN AUTOMÁTICA DEL SERVICIO FASTAPI
# ===============================================

# --- Variables de configuración ---
REPO_URL="https://github.com/Chuluet/Taller-EC2.git"
PROJECT_DIR="/home/ubuntu/taller-ec2"
ENV_NAME="fastapi_env"
CONDA_PATH="/home/ubuntu/miniconda3"

# --- Actualizar sistema e instalar dependencias básicas ---
sudo apt update -y
sudo apt install -y git wget curl

# --- Instalar Miniconda (si no está instalado) ---
if [ ! -d "$CONDA_PATH" ]; then
    echo "Instalando Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
    bash ~/miniconda.sh -b -p $CONDA_PATH
    eval "$($CONDA_PATH/bin/conda shell.bash hook)"
    conda init
else
    echo "✅ Miniconda ya está instalada."
    eval "$($CONDA_PATH/bin/conda shell.bash hook)"
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
    conda create -n $ENV_NAME python=3.10 -y
else
    echo "✅ Entorno conda ya existe."
fi

# --- Instalar dependencias dentro del entorno ---
echo "Instalando dependencias en el entorno..."
$CONDA_PATH/envs/$ENV_NAME/bin/pip install -r requirements.txt

# --- Configurar servicio systemd ---
echo "Configurando servicio FastAPI..."
sudo bash -c "cat > /etc/systemd/system/fastapi.service" <<EOF
[Unit]
Description=FastAPI service
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=$PROJECT_DIR
ExecStart=$CONDA_PATH/envs/$ENV_NAME/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable fastapi
sudo systemctl restart fastapi

echo "✅ Configuración completa. El servicio está corriendo en el puerto 8000."
echo "Prueba con: curl -X POST http://<IP_PUBLICA>:8000/insert/ -H 'Content-Type: application/json' -d '{\"name\": \"Mateo\", \"edad\": 20, \"fecha_nacimiento\": \"2003-01-01\"}'"
