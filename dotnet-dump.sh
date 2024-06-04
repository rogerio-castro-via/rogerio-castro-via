#!/bin/bash

# Função para executar o dump
executar_dump() {
    kubectl exec -it "$POD_NAME" -- /bin/bash <<'EOF'
    apt-get update
    apt-get install -y wget
    wget -O dotnet-dump https://aka.ms/dotnet-dump/linux-x64
    wget -O dotnet-trace https://aka.ms/dotnet-trace/linux-x64
    chmod 777 ./dotnet-dump
    chmod 777 ./dotnet-trace
    ./dotnet-dump collect -p 1 --diag
    ./dotnet-trace collect --clreventlevel 5 --providers '*' --duration 00:00:03:00 -p 1

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


SOURCE_PATH="/app"  # Substitua pelo caminho onde os arquivos de dump estão no pod
DEST_PATH="/home/rogerio/scripts/"   # Substitua pelo caminho onde deseja salvar os arquivos localmente

# Listar arquivos de dump no pod
FILES=$(kubectl exec -it "$POD_NAME"  -- /bin/bash -c "ls $SOURCE_PATH/core_*" | tr -d '\r')
# Loop para copiar cada arquivo
for FILE in $FILES; do
    FILENAME=$(basename "$FILE")
    kubectl cp "$POD_NAME:$FILE" "$DEST_PATH/$FILENAME"
done

