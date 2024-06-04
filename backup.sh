#!/bin/bash

NAMESPACE="bonificacao-prd"
BACKUP_DIR="/home/rogerio/scripts/rogerio-castro-via/backup"

mkdir -p $BACKUP_DIR

# Lista de tipos de recursos para exportar
RESOURCES=("pods" "services" "deployments" "replicasets" "configmaps" "secrets" "ingresses" "persistentvolumeclaims" "statefulsets" "daemonsets" "jobs" "cronjobs" "networkpolicies")

for resource in "${RESOURCES[@]}"; do
    echo "Exportando $resource..."
    mkdir -p $BACKUP_DIR/$resource
    for item in $(kubectl get $resource -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}'); do
        echo "Exportando $resource $item..."
        kubectl get $resource $item -n $NAMESPACE -o yaml | kubectl neat > $BACKUP_DIR/$resource/$item.yaml
    done
done

# Archive the backup files
BACKUP_FILE="$BACKUP_DIR/backup_$(date +'%Y%m%d%H%M%S').tar.gz"
tar -czvf $BACKUP_FILE -C $BACKUP_DIR .

# Upload to Azure Blob Storage
STORAGE_ACCOUNT_NAME="capacidadebkp"
STORAGE_ACCOUNT_KEY="Jw3wew0XLEIUH049CHlw3s3nl9NT+BH7i8bb4QfUKG9DDI0qcykaFkofptY1u5dbdX4ynBwGL53D+ASt37rZGw=="
CONTAINER_NAME="backup"

# Instale o Azure CLI se não estiver instalado
# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login no Azure
az storage blob upload --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_ACCOUNT_KEY --container-name $CONTAINER_NAME --file $BACKUP_FILE --name $(basename $BACKUP_FILE)
