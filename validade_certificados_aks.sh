#!/bin/bash

# Define o formato da data e hora para o nome do arquivo
date_format="%Y-%m-%d_%H-%M-%S"
# Obtém a data e hora atual
current_datetime=$(date +"$date_format")
# Nome do arquivo com base na data e hora atual
output_file="expired_certificates_$current_datetime.txt"

# Lista todas as namespaces no cluster
namespaces=$(kubectl get namespaces -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}')

# Obtém a data atual em formato Unix timestamp
current_timestamp=$(date +%s)

# Loop através de cada namespace
for NAMESPACE in $namespaces; do
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

                # Obtém a data de validade do certificado em formato Unix timestamp
                expiration_timestamp=$(date -d "$(echo "$cert" | openssl x509 -noout -enddate | cut -d= -f2)" +%s)

                # Verifica se o certificado está vencido
                if [ $expiration_timestamp -lt $current_timestamp ]; then
                    # Escreve as informações do certificado vencido no arquivo de saída
                    echo -e "$NAMESPACE\t$key\t$(date -d@$expiration_timestamp '+%Y-%m-%d %H:%M:%S')" >> "$output_file"
                fi
            fi
        done
    done
done

echo "Verificação de certificados concluída. Certificados vencidos salvos em: $output_file"
