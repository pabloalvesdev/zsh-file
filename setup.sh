#!/bin/bash

# Interromper o script caso ocorra algum erro
set -e

echo "=== CONFIGURADOR AUTOMATIZADO ==="
echo ""

# 1. Perguntar pelos arquivos e credenciais
read -p "Informe o caminho completo ou relativo do arquivo .tar.xz do Node.js: " NODE_FILE
read -p "Informe o caminho completo ou relativo do arquivo .deb do VS Code: " VSCODE_FILE
echo ""
read -p "Informe o nome de usuário desejado para o PostgreSQL (ex: postgres): " PG_USER
read -s -p "Informe a senha desejada para o PostgreSQL: " PG_PASS
echo ""
read -p "Informe o nome do banco de dados inicial do PostgreSQL (ex: meu_banco): " PG_DB

echo ""
echo "=== 1. Atualizando o sistema e instalando dependências básicas (Git, Curl, etc.) ==="
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git wget apt-transport-https ca-certificates gnupg lsb-release

echo "=== 2. Instalando o Node.js a partir do arquivo informado ==="
if [ -f "$NODE_FILE" ]; then
    NODE_DIR=$(basename "$NODE_FILE" .tar.xz)
    # Se o arquivo tiver .tar.xz duplo ou extensão composta, ajusta a extração
    NODE_DIR=${NODE_DIR%.tar}
    
    tar -xf "$NODE_FILE"
    sudo rm -rf /opt/node
    sudo mv "$NODE_DIR" /opt/node
    
    if ! grep -q "/opt/node/bin" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# Node.js PATH" >> ~/.bashrc
        echo "export NODE_HOME=/opt/node" >> ~/.bashrc
        echo "export PATH=\$NODE_HOME/bin:\$PATH" >> ~/.bashrc
        echo "Node.js configurado no .bashrc com sucesso!"
    fi
else
    echo "Erro: Arquivo do Node.js não encontrado em '$NODE_FILE'. Pulando esta etapa."
fi

echo "=== 3. Instalando o VS Code a partir do arquivo .deb informado ==="
if [ -f "$VSCODE_FILE" ]; then
    sudo apt install -y "$VSCODE_FILE"
    echo "VS Code instalado com sucesso!"
else
    echo "Erro: Arquivo do VS Code não encontrado em '$VSCODE_FILE'. Pulando esta etapa."
fi

echo "=== 4. Instalando e configurando o Docker ==="
if ! command -v docker &> /dev/null; then
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    sudo usermod -aG docker $USER
    echo "Docker instalado com sucesso!"
else
    echo "Docker já está instalado."
fi

echo "=== 5. Criando e subindo o container PostgreSQL via Docker ==="
if [ "$(docker ps -a -q -f name=meu-postgres)" ]; then
    echo "Removendo container antigo do postgres..."
    docker rm -f meu-postgres
fi

docker run --name meu-postgres \
  --restart unless-stopped \
  -e POSTGRES_USER="$PG_USER" \
  -e POSTGRES_PASSWORD="$PG_PASS" \
  -e POSTGRES_DB="$PG_DB" \
  -p 5432:5432 \
  -d postgres:latest

echo "=== 6. Instalando o FocalBoard ==="
docker run -d \
  --name focalboard \
  --restart unless-stopped \
  -p 8000:8000 \
  -v ~/docker/focalboard/data:/opt/focalboard/data \
  mattermost/focalboard

echo "=== 7. Instalando o Waydroid ==="

sudo apt install curl ca-certificates -y
curl -s https://repo.waydro.id | sudo bash
sudo apt update
sudo apt install waydroid -y

echo "=== 7. Definindo propriedades personalizadas do Waydroid ==="
sudo waydroid init || true

# Garante o ambiente do D-Bus do usuário
export XDG_RUNTIME_DIR=/run/user/$(id -u)

echo "=== 1. Iniciando a sessão do Waydroid ==="
waydroid session start &

echo "Aguardando o serviço subir (5 segundos)..."
sleep 25

echo "=== 2. Aplicando as propriedades de resolução ==="
waydroid prop set persist.waydroid.width 400
waydroid prop set persist.waydroid.height 400
waydroid prop set persist.waydroid.suspend_background false

echo "=== 3. Parando a sessão atual ==="
waydroid session stop
sleep 2

echo "=== 4. Reiniciando o container do sistema para consolidar as mudanças ==="
sudo systemctl restart waydroid-container
sleep 3

echo "=== 5. Reiniciando a sessão com os novos tamanhos aplicados ==="
waydroid session start &

echo "=== 6. Configurando varivaies globais do GIT"
git config --global user.name "Pablo Alves"
git config --global user.email "pabloalves.dev@gmail.com"

echo "=== TUDO PRONTO! ==="
echo "Por favor, feche e abra o terminal novamente (ou execute 'source ~/.bashrc') para carregar o Node.js."
