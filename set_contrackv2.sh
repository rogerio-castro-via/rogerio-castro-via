#!/bin/bash

# Verifica se o contexto está definido para o cluster pricing
current_context=$(kubectl config current-context)
if [ "$current_context" != "akspriv-pricing-prd-admin" ]; then
    echo "O contexto atual não está definido para o cluster pricing."
    exit 1
fi

# Obtém a data e hora atual em segundos desde a época
current_time=$(date +%s)

for node in $(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name} {.metadata.creationTimestamp}{"\n"}{end}'); do
    node_name=$(echo "$node" | awk '{print $1}')
    creation_timestamp=$(echo "$node" | awk '{print $2}')

    # Converte a data de criação do nó para segundos desde a época
    node_creation_time=$(date -d "$creation_timestamp" +%s)

    # Calcula a diferença em segundos entre o tempo atual e o tempo de criação do nó
    time_difference=$((current_time - node_creation_time))

    # Verifica se a diferença de tempo é menor que 1 dia (86400 segundos)
    if [ "$time_difference" -lt 86400 ]; then
        echo "Node: $node_name"
        echo "Tempo desde a criação do nó: $time_difference segundos"
        # Aplicar alterações apenas se o contexto estiver correto e o nó foi iniciado há menos de 1 dia
        # kubectl node-shell $node_name -- sysctl -w net.netfilter.nf_conntrack_max=1048576
    fi
done
