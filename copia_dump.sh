#!/bin/bash

# Variáveis
POD_NAME=$(kubectl get pods  | grep bahia | awk '{print $1}' | tail -1)  # Substitua "nomedopod" pelo nome do seu pod
SOURCE_PATH="/app"  # Substitua pelo caminho onde os arquivos de dump estão no pod
DEST_PATH="/home/rogerio/k6"   # Substitua pelo caminho onde deseja salvar os arquivos localmente

# Listar arquivos de dump no pod
FILES=$(kubectl exec -it "$POD_NAME"  -- /bin/bash -c "ls $SOURCE_PATH/core_*" | tr -d '\r')

# Loop para copiar cada arquivo
for FILE in $FILES; do
    FILENAME=$(basename "$FILE")
    kubectl cp "$NAMESPACE/$POD_NAME:$FILE" "$DEST_PATH/$FILENAME"
done
