#!/bin/bash

# Função para executar o dump
executar_dump() {
    kubectl exec -it "$POD_NAME" -- /bin/bash <<'EOF'
    apt-get update
    apt-get install -y wget
    wget -O dotnet-dump https://aka.ms/dotnet-dump/linux-x64
    chmod 777 ./dotnet-dump
<<<<<<< HEAD
    ./dotnet-dump collect -p 1 --diag
=======
    ./dotnet-dump collect -p 1
>>>>>>> 840ce14921b4ef465a1d2c2fdae9106109e96eed
EOF
}

# Variáveis
POD_NAME=$(kubectl get pods | grep bahia | awk '{print $1}' | tail -1)  # Substitua "bahia" pelo critério de busca para encontrar o pod
echo "$POD_NAME"
# Executar a função quatro vezes
for ((i=1; i<=3; i++)); do
    echo "Executando dump número $i..."
    executar_dump
    echo "Dump número $i concluído."
    sleep 15s  # Aguardar 15 segundos antes de iniciar a próxima coleta
done
