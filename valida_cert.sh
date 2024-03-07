#!/bin/bash

# Namespace do Kubernetes
NAMESPACE="kafka-cluster"

# Lista todas as secrets na namespace
secrets=$(kubectl get secrets -n $NAMESPACE -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}')

# Loop através de cada secret
for secret in $secrets; do
    # Obtém os dados da secret
    secret_data=$(kubectl get secret $secret -n $NAMESPACE -o=jsonpath='{.data}')

    # Loop através de cada chave na secret
    for key in $(echo $secret_data | jq -r 'keys[]'); do
        # Verifica se o valor da chave é um certificado
        if echo "$key" | grep -q ".crt"; then
            # Obtém o certificado e decodifica (se base64)
            cert=$(echo "$secret_data" | jq -r ".\"$key\"" | base64 -d)

            # Obtém a data de validade do certificado
            expiration_date=$(echo "$cert" | openssl x509 -noout -enddate | cut -d= -f2)

            # Mostra as informações do certificado
            echo "Certificado: $key"
            echo "Data de Expiração: $expiration_date"
            echo "----------------------------------------"
        fi
    done
done
