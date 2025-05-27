#!/bin/bash

# ========================[ Validação de Permissão ]==========================
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n\e[1;31m[✗ ERRO]\e[0m \e[31mExecute o script como root!\e[0m\n"
    exit 1
fi

# ========================[ Configurações de Rede ]===========================
INTERFACE="enp0s3"
IP_ADDRESS="192.168.21.106"
NETMASK="25"
GATEWAY="192.168.21.126"
DNS="8.8.8.8"
DNS2="8.8.4.4"

# ========================[ Função: Validação de IP ]=========================
validate_ip() {
    local ip=$1
    local stat=1
    if [[ $ip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
        OIFS=$IFS; IFS='.'; ip=($ip); IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && \
           ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# ========================[ Validações Iniciais ]=============================
echo -e "\e[1;36m🔍 Verificando Interface e IP...\e[0m"

if ! ip link show $INTERFACE &> /dev/null; then
    echo -e "\e[1;31m[✗ ERRO]\e[0m \e[31mInterface $INTERFACE não encontrada!\e[0m"
    exit 1
fi

if ! validate_ip $IP_ADDRESS; then
    echo -e "\e[1;31m[✗ ERRO]\e[0m \e[31mEndereço IP $IP_ADDRESS inválido!\e[0m"
    exit 1
fi

# ========================[ Aplicando Configurações ]=========================
echo -e "\n\e[1;34m🌐 Iniciando configuração da interface $INTERFACE...\e[0m"

echo -e "\n\e[34m[1/5] ⛔ Desativando interface...\e[0m"
ip link set $INTERFACE down || { echo -e "\e[1;31m[✗ ERRO] Falha ao desativar interface\e[0m"; exit 1; }

echo -e "\e[34m[2/5] ⚙️  Configurando IP: $IP_ADDRESS/$NETMASK...\e[0m"
ip addr flush dev $INTERFACE
ip addr add $IP_ADDRESS/$NETMASK dev $INTERFACE || { echo -e "\e[1;31m[✗ ERRO] Falha ao configurar IP\e[0m"; exit 1; }

echo -e "\e[34m[3/5] ✅ Ativando interface...\e[0m"
ip link set $INTERFACE up || { echo -e "\e[1;31m[✗ ERRO] Falha ao ativar interface\e[0m"; exit 1; }

echo -e "\e[34m[4/5] 🚪 Configurando gateway: $GATEWAY...\e[0m"
ip route add default via $GATEWAY || { echo -e "\e[1;31m[✗ ERRO] Falha ao configurar gateway\e[0m"; exit 1; }

echo -e "\e[34m[5/5] 🧭 Configurando DNS: $DNS...\e[0m"
echo -e "nameserver $DNS\nnameserver $DNS2" > /etc/resolv.conf || { echo -e "\e[1;31m[✗ ERRO] Falha ao configurar DNS\e[0m"; exit 1; }

# ========================[ Exibindo Resultado ]==============================
echo -e "\n\e[1;32m✅ Configuração aplicada com sucesso!\e[0m"

echo -e "\n\e[1;33m📡 Interface: $INTERFACE\e[0m"
ip addr show $INTERFACE

echo -e "\n\e[1;33m🗺️  Roteamento:\e[0m"
ip route show

echo -e "\n\e[1;33m🧭 DNS Configurado:\e[0m"
cat /etc/resolv.conf

# ========================[ Testes de Conectividade ]=========================
echo -e "\n\e[1;36m🔌 Testando conectividade...\e[0m"

ping -c 2 $GATEWAY &> /dev/null
[[ $? -eq 0 ]] && echo -e "\e[32m✓ Gateway ($GATEWAY) alcançável\e[0m" || echo -e "\e[31m✗ Falha ao alcançar o gateway ($GATEWAY)\e[0m"

ping -c 2 $DNS &> /dev/null
[[ $? -eq 0 ]] && echo -e "\e[32m✓ DNS ($DNS) funcionando\e[0m" || echo -e "\e[31m✗ Falha ao alcançar o DNS ($DNS)\e[0m"

echo -e "\n\e[1;32m🎉 Configuração finalizada com sucesso!\e[0m"