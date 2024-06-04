#!/bin/bash
# Script que faz backup de todos os componentes de todas as namespaces.
DATA=$(date +%F-%H-%M)
BACKUP_DIR="./backup_$DATA"

mkdir -p $BACKUP_DIR

# Lista de tipos de recursos para exportar
RESOURCES=("hpa" "services" "deployments" "configmaps" "secrets" "ingresses" "persistentvolumeclaims" "statefulsets" "daemonsets" "jobs" "cronjobs" "networkpolicies")

# Obter todas as namespaces
NAMESPACES=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

for NAMESPACE in $NAMESPACES; do
    echo "Exportando recursos da namespace $NAMESPACE..."
    for resource in "${RESOURCES[@]}"; do
        echo "Exportando $resource na namespace $NAMESPACE..."
        mkdir -p $BACKUP_DIR/$NAMESPACE/$resource
        for item in $(kubectl get $resource -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}'); do
            echo "Exportando $resource $item na namespace $NAMESPACE..."
            kubectl get $resource $item -n $NAMESPACE -o yaml | kubectl neat > $BACKUP_DIR/$NAMESPACE/$resource/$item.yaml
        done
    done
done
