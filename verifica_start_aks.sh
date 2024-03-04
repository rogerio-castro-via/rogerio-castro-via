#!/bin/bash

# Obtém os contextos que contêm "hlg-admin"
clusters=$(kubectx | grep hlg-admin)

# Verifica se há contextos encontrados
if [ -z "$clusters" ]; then
    echo "Nenhum contexto contendo 'hlg-admin' encontrado."
    exit 1
fi

# Itera sobre os contextos encontrados
for i in $clusters; do
    echo "Switching to context: $i"
    kubectx $i

    # Verifica se a troca de contexto foi bem-sucedida
    if [ $? -ne 0 ]; then
        echo "Falha ao mudar para o contexto: $i"
        exit 1
    fi

    echo "Nodes no contexto: $i"
    kubectl get nodes

    # Verifica se o comando kubectl foi bem-sucedido
    if [ $? -ne 0 ]; then
        echo "Falha ao obter os nós no contexto: $i"
        exit 1
    fi
done
