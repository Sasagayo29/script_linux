#!/bin/bash

echo -e "\033[1mVerificando se o Samba está instalado...\033[0m"
sleep 2

if dpkg -s samba &> /dev/null; then
	echo -e "Samba já instalado ✅️"
else
	echo -e "Samba não encontrado. Inicializando instalação..."
	sudo apt-get update
	sudo apt-get -y insatll samba smbcliente
	echo -e "Samba instalado com sucesso ✅️"
fi
sleep 2

echo -e "\033[1mVerificando se o Net-Tools está instalado...\033[0m"
sleep 2

if dpkg -s net-tools &> /dev/null; then
	echo -e "Net-Tools já instalado ✅️"
else
	echo -e "Net-Tools não encontrado. Inicializando instalação..."
	sudo apt-get update
	sudo apt-get -y insatll net-tools
	echo -e "Net-Tools instalado com sucesso ✅️"
fi
sleep 3

clear

echo "Informe o nome do groupo de trabalho de sua máquina"
echo "Se você não souber, insira o seguinte comando no windows do seu computador"
echo -e "\033[1msysteminfo | findstr /C:''Domínio''\033[0m"
echo ""
read workgroup
clear
echo ""
echo "==============================================================================="
echo "			*** Informações sobre sua rede 🤖️ ***" 
echo "==============================================================================="
echo ""
sudo ifconfig
echo "==============================================================================="
echo ""
echo "Informe o nome da sua interface de rede."
read interface
echo "Informe o ip da sua interface de rede."
read ip
clear

if [ ! -f /etc/samba/smb.conf_bkp ]; then
	echo -e "\033[1mBackup do  smb.conf ainda não existe. Criando backup...\033[0m"
	sudo  mv /etc/samba/smb.conf /etc/samba/smb.conf_bkp
	echo -e "smb.conf_bkp criado com sucesso ✅️"
else
	echo "Backup do smb.conf já existe ."
fi
echo -e "\033[1mCriando novo arquivo smb.conf...\033[0m"
sleep 2

sudo bash -c "cat > /etc/samba/smb.conf" << EOF
# ------------------------GLOBAL-----------------------------------------------
[global]
workgroup = $workgroup
interfaces = $ip/24 $interface
server string = Samba Server %v
netbios name = debian
security = user
map to guest = bad user
dns proxy = no
# ------------------------SERVIDOR-----------------------------------------------
[Servidor]
comment = Compartilhamento do Servidor
path = /home/shares/Servidor
valid useres = @users
force group = users
create mask = 0777
directory mask = 0777
writable = yes
# ------------------------HOMES-----------------------------------------------
[homes]
comment = Diretório Home
browseable = no
valid users = %S
writable = yes
create mask = 0777
directory mask = 0777
EOF
echo -e "Novo smb.conf criado com sucesso ✅️"

sudo systemctl restart smbd nmbd samba
sudo mkdir -p /home/shares/Servidor
chmod 770 /home/shares/Servidor
chown -R root:users /home/shares/Servidor/
chmod -R ug+rwx,o+rx-w /hom/shares/Servidor/

sudo systemctl restart smbd.service nmbd samba

clear
echo "==============================================================================="
echo "			   *** Cadastro de Usuários ***" 
echo "==============================================================================="
echo " Quantos usuários você deseja cadastrar? "
read num

for i in $(seq 1 $num)
do
	echo "Informe o nome do usuário"
	read user
	sudo useradd $user -m -G users
	sudo passwd $user
	echo -e "Usuário criado com sucesso ✅️"
	sleep 3
	sudo smbpasswd -a $user
done

clear

echo ""
echo "==============================================================================="
echo "			*** Criação de Pasta ***" 
echo "==============================================================================="
echo ""
echo " Quantas pasta você deseja criar? "
read num
for i in $(seq 1 $num)
do
	echo "Informe o nome da pasta"
	read pasta
	sudo mkdir /home/shares/Servidor/$pasta
	sudo chmod 770 -R /home/shares/Servidor/$pasta
	echo -e "Pasta criada com sucesso ✅️"
	echo "Qual usuário será o dono da pasta?"
	read user
	sudo chown -R $user: /home/shares/Servidor/$pasta
	echo -e "$user foi adicionado como propietário da pasta /home/shares/Servidor/$pasta ✅️"
	sudo systemctl restart smbd
done










