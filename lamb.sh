#!/bin/bash

# lamb.sh - Instalação do LAMP (Linux, Apache, MySQL, PHP)

echo "Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

echo "Instalando Apache..."
sudo apt install apache2 -y

echo "Instalando MySQL..."
sudo apt install mysql-server -y
sudo mysql_secure_installation

echo "Instalando PHP..."
sudo apt install php libapache2-mod-php php-mysql -y

echo "Reiniciando Apache..."
sudo systemctl restart apache2

echo "Verificando status dos serviços..."
sudo systemctl status apache2
sudo systemctl status mysql

echo "Instalação do LAMP concluída!"
