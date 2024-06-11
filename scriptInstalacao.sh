echo "Bem vindo, este script irá configurar a sua máquina e iniciar a aplicação em seu totem!"

# Verificar se Docker está instalado
if ! which docker &> /dev/null
then
    echo "Instalando docker docker na máquina"

    # Atualizar pacotes existentes
    sudo apt-get update

    # Remover versões antigas do Docker
    sudo apt-get remove -y docker docker-engine docker.io containerd runc

    # Instalar pacotes necessários para usar o repositório APT sobre HTTPS
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Adicionar a chave GPG oficial do Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Adicionar o repositório do Docker às fontes do APT
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # Atualizar pacotes do APT novamente para incluir pacotes do Docker
    sudo apt-get update

    # Instalar Docker CE
    sudo apt-get install -y docker-ce

    # Adicionar o usuário atual ao grupo Docker
    sudo usermod -aG docker $USER


    echo "Docker foi instalado com sucesso."

    sudo systemctl restart docker

else
    echo "Verificamos que você já possui Docker em sua máquina."
fi


# Verificar se Docker Compose está instalado
if ! which docker-compose &> /dev/null
then

    echo "Instalando Docker Compose"

    # Instalar Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    # Aplicar permissões corretas ao binário do Docker Compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Criar um link simbólico para Docker Compose em /usr/bin se não existir
    if [ ! -f /usr/bin/docker-compose ]; then
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi

    echo "Docker Compose instalado com sucesso."
else
    echo "Verificamos que você já possui Docker Compose instalado em sua máquina."
fi

# Verificar instalação
sudo docker --version

sudo docker-compose --version

cat <<EOF > docker-compose.yml
version: '3.3'

services:
  app:
    image: gabrielamaralll/totemtech-jar-image
    restart: always
    container_name: my-app-container
    environment:
      - DB_HOST=localhost
      - DB_PORT=3306
      - DB_USER=totemMaster
      - DB_PASSWORD=12345
      - DB_NAME=totemTech
    depends_on:
      - db
    network_mode: host
    stdin_open: true
    tty: true
    ports:
      - "8080:8080"

  db:
    image: tallyon26655/totem-tech
    restart: always
    container_name: my-db-container
    ports:
      - "3306:3306"
    environment:
     MYSQL_ROOT_PASSWORD: urubu100
    network_mode: host
    command: --init-file /data/application/init.sql
    volumes:
     - ./init.sql:/data/application/init.sql

networks:
  totemtech_net:
    driver: bridge
    ipam:
      driver: default

EOF

cat <<EOF > init.sql
CREATE USER 'totemMaster'@'%' IDENTIFIED BY '12345';
GRANT ALL PRIVILEGES ON *.* TO 'totemMaster'@'%';
FLUSH PRIVILEGES;
EOF

sudo docker compose up -d

rm init.sql
rm docker-compose.yml

clear

sudo docker exec -it my-app-container java -jar app.jar