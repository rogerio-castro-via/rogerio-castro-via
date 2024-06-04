#!/bin/bash
POD_NAME=$(kubectl get pods | grep bahia | awk '{print $1}' | tail -1)  # Substitua "bahia" pelo critério de busca para encontrar o pod
echo "$POD_NAME"
SOURCE_PATH="/app"  # Substitua pelo caminho onde os arquivos de dump estão no pod
DEST_PATH="/home/rogerio/scripts/"   # Substitua pelo caminho onde deseja salvar os arquivos localmente

# Listar arquivos de dump no pod
FILES=$(kubectl exec -it "$POD_NAME"  -- /bin/bash -c "ls $SOURCE_PATH/dotnet*" | tr -d '\r')
# Loop para copiar cada arquivo
for FILE in $FILES; do
    FILENAME=$(basename "$FILE")
    kubectl cp "$POD_NAME:$FILE" "$DEST_PATH/$FILENAME"
done

