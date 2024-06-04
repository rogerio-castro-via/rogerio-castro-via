#!/bin/bash

namespace="kafka-cluster"

# Obter a lista de secrets na namespace especificada
secrets=$(kubectl get secrets -n "$namespace" --field-selector type=kubernetes.io/tls --output=jsonpath='{.items[*].metadata.name}')

# Verificar cada secret em busca de certificados SSL expirados
for secret in $secrets; do
    # Obter a data de expiração do certificado SSL
    expiration_date=$(kubectl get secret "$secret" -n "$namespace" --output=jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -enddate -noout | awk -F '=' '{print $2}')

    # Converter a data de expiração para um formato legível
    expiration_epoch=$(date -d "$expiration_date" +%s)
    current_epoch=$(date +%s)

    # Verificar se o certificado SSL está expirado
    if (( current_epoch > expiration_epoch )); then
        echo "Certificado SSL expirado encontrado no secret: $secret"
    else
        echo "Certificado SSL válido encontrado no secret: $secret"
    fi
done
