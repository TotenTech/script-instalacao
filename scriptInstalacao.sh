#!/bin/bash

# Verifica se o MySQL está instalado
if ! command -v mysql &> /dev/null
then
    echo "MySQL não encontrado. Instalando..."
    sudo apt update
    sudo apt install mysql-server
    echo "MySQL instalado com sucesso."
    
else
    echo "MySQL já está instalado."
fi

# Start o Mysql service
sudo service mysql start

# Configura a senha do usuário root do MySQL
if sudo mysql -e "SELECT 1;" &> /dev/null
then
    echo "MySQL está em execução."
    #read -sp "Digite a senha do usuário root do MySQL: " MYSQL_ROOT_PASSWORD
    # Ou caso queira um script completamente automatico 
else
    echo "Erro: MySQL não está em execução."
    exit 1
fi

# Reinicia o serviço do MySQL
echo "Reiniciando o serviço do MySQL..."
sudo service mysql restart

# Configurações do MySQL
MYSQL_USER="root"
MYSQL_DATABASE="totemTech"

git clone https://github.com/TotenTech/TotemTech-Main.git
git clone https://github.com/TotenTech/database.git
git clone https://github.com/TotenTech/client.git


cd database
sudo mysql -u root < script.sql

java -version  # Verifica a versão atual do Java

if [ $? = 0 ]; then
    echo "Java instalado"
else
    echo "Java não instalado"
        sudo apt install openjdk-17-jre -y
fi

cd ..
cd client
cd login-totemtech-client
cd target
clear
java -jar login-totemtech-1.0-SNAPSHOT-jar-with-dependencies.jar