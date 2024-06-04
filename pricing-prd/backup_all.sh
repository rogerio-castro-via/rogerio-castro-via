#!/bin/bash
# Script que faz backup de todos os componentes de determinada namespace.

NAMESPACE="api-preco-b2c-prd"
BACKUP_DIR="./backup"

mkdir -p $BACKUP_DIR

# Lista de tipos de recursos para exportar
RESOURCES=("hpa" "services" "deployments" "configmaps" "secrets" "ingresses" "persistentvolumeclaims" "statefulsets" "daemonsets" "jobs" "cronjobs" "networkpolicies")

for resource in "${RESOURCES[@]}"; do
    echo "Exportando $resource..."
    mkdir -p $BACKUP_DIR/$resource
    for item in $(kubectl get $resource -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}'); do
        echo "Exportando $resource $item..."
        kubectl get $resource $item -n $NAMESPACE -o yaml | kubectl neat > $BACKUP_DIR/$resource/$item.yaml
    done
done
