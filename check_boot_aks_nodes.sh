#!/bin/bash

# Definindo a variável do nome do seu cluster AKS
AKS_CLUSTER_NAME="akspriv-feed-hlg-admin"
RESOURCE_GROUP="rg-feed-app-hlg"

# Obtendo a lista de nós do AKS
node_list=$(az aks node list --resource-group $RESOURCE_GROUP --cluster-name $AKS_CLUSTER_NAME --query '[].{Name:name, ProvisioningState:provisioningState, StartTime:startTime}' -o tsv)

# Obtendo a data atual em segundos desde o epoch
current_time=$(date +%s)

# Iterando sobre a lista de nós
echo "Nodes iniciados há mais de 4 horas no cluster AKS '$AKS_CLUSTER_NAME':"
echo "-------------------------------------------------------------"
while IFS=$'\t' read -r node_name provisioning_state start_time; do
    # Convertendo a data de início do nó para segundos desde o epoch
    node_start_time=$(date -d "$start_time" +%s)

    # Calculando o tempo decorrido desde a inicialização do nó em horas
    elapsed_hours=$(( ($current_time - $node_start_time) / 3600 ))

    # Verificando se o nó foi iniciado há mais de 4 horas
    if [ $elapsed_hours -ge 4 ]; then
        echo "Node: $node_name, Tempo decorrido: $elapsed_hours horas"
    fi
done <<< "$node_list"
