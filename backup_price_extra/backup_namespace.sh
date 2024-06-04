#!/bin/bash
NAMESPACE="api-preco-b2c-prd"
BACKUP_DIR="./backup"

mkdir -p $BACKUP_DIR

# Lista de tipos de recursos para exportar
RESOURCES=("services" "deployments" "replicasets" "configmaps" "secrets" "ingresses" "persistentvolumeclaims" "statefulsets" "daemonsets" "jobs" "cronjobs" "networkpolicies")

for resource in "${RESOURCES[@]}"; do
    echo "Exportando $resource..."
    mkdir -p $BACKUP_DIR/$resource
    for item in $(kubectl get $resource -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}'); do
        echo "Exportando $resource $item..."
        kubectl get $resource $item -n $NAMESPACE -o yaml > $BACKUP_DIR/$resource/$item.yaml
    done
done

