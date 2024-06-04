#!/bin/bash

# Nome do deployment que você quer descrever
deployment_name="api-preco-casasbahia"

# Nome do arquivo de saída
output_file="describe_${deployment_name}_pods.txt"

# Obter lista de pods do deployment
pods=$(kubectl get pods -l app=$deployment_name -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}')

# Loop através de cada pod
for pod in $pods; do
    # Descrever o pod e salvar a descrição no arquivo de saída
    kubectl describe pod $pod >> "$output_file"
    echo -e "\n\n" >> "$output_file"  # Adicionar linhas em branco entre as descrições dos pods
done

echo "Descrição dos pods do deployment '$deployment_name' salva em: $output_file"

