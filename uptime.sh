#!/bin/bash

# Definindo lista de servidores
servers=("10.128.8.120" "10.128.8.121" "10.128.8.126" "10.128.8.127" "10.128.8.128" "10.128.8.172" "10.128.8.173" "10.128.8.174" "10.128.8.116" "10.128.8.183" "10.128.8.181" "10.128.8.219" "10.128.8.247" "10.128.8.248" "10.128.8.249")

# Definindo usuário e senha
username="sre_b2b"
password="#*YgGdr@$1L#*"

# Loop através da lista de servidores
for server in "${servers[@]}"
do
# Executando comando "uptime" remotamente usando SSH e gravando a saída em um arquivo temporário no servidor remoto
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username"@"$server" /usr/bin/uptime 
    
    # Lendo o arquivo temporário com o resultado do comando "uptime" usando SSH
    #sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username"@"$server" "cat /tmp/uptime_result.txt"
    
    echo "==============================="
done
