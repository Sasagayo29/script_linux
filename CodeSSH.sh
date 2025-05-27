#!/bin/bash

# Atualizar os pacotes
echo "Atualizando pacotes..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Definir as interfaces de rede
# Suponha que a interface WAN seja eth0 e a interface LAN seja eth1
WAN_INTERFACE="eth0"
LAN_INTERFACE="eth1"

# Configurar IPs estáticos nas interfaces
# IP para a WAN
sudo ip addr add 192.168.1.2/24 dev $WAN_INTERFACE
# Gateway para a WAN
WAN_GATEWAY="192.168.1.1"
sudo ip route add default via $WAN_GATEWAY

# IP para a LAN
sudo ip addr add 192.168.100.1/24 dev $LAN_INTERFACE

# Ativar o roteamento entre as interfaces
sudo sysctl -w net.ipv4.ip_forward=1

# Configurar a NAT (Network Address Translation) para permitir acesso à internet para a LAN
sudo iptables -t nat -A POSTROUTING -o $WAN_INTERFACE -j MASQUERADE

# Permitir o tráfego da LAN para a WAN
sudo iptables -A FORWARD -i $LAN_INTERFACE -o $WAN_INTERFACE -j ACCEPT

# Permitir o tráfego da WAN para a LAN
sudo iptables -A FORWARD -i $WAN_INTERFACE -o $LAN_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

# Configurar o firewall para bloquear tráfego não autorizado (apenas exemplo básico)
# Permitir tráfego ICMP (ping)
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
# Permitir tráfego SSH na porta 22
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
# Bloquear tudo o mais
sudo iptables -A INPUT -j DROP

# Configurar o DNS (supondo que você use o DNS público do Google)
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

# Configuração do DHCP (se necessário)
# Supondo que você queira configurar o servidor DHCP na rede interna (LAN)
# Instalar o pacote DHCP se necessário
# sudo apt-get install isc-dhcp-server

# Editar o arquivo de configuração do DHCP
# Configurar intervalo de IPs para a rede LAN, por exemplo, 192.168.100.10 até 192.168.100.100
# Adicionar essas linhas ao arquivo /etc/dhcp/dhcpd.conf (após a instalação do servidor DHCP)
echo "subnet 192.168.100.0 netmask 255.255.255.0 {" | sudo tee -a /etc/dhcp/dhcpd.conf
echo "  range 192.168.100.10 192.168.100.100;" | sudo tee -a /etc/dhcp/dhcpd.conf
echo "  option routers 192.168.100.1;" | sudo tee -a /etc/dhcp/dhcpd.conf
echo "  option domain-name-servers 8.8.8.8, 8.8.4.4;" | sudo tee -a /etc/dhcp/dhcpd.conf
echo "}" | sudo tee -a /etc/dhcp/dhcpd.conf

# Reiniciar o serviço DHCP
# sudo systemctl restart isc-dhcp-server

# Reiniciar o roteador para aplicar todas as configurações
sudo systemctl reboot