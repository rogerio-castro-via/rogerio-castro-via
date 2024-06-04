#!/bin/bash
#az login

kubectx "@option.Cluster@"
# Define o formato da data e hora para o nome do arquivo
date_format="%Y-%m-%d_%H-%M-%S"
# Obtém a data e hora atual
current_datetime=$(date +"$date_format")
# Nome do arquivo com base na data e hora atual
output_file="@option.Cluster@""-certificates_check_$current_datetime.txt"

# Lista todas as namespaces no cluster
namespaces=$(kubectl get namespaces -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}')

# Loop através de cada namespace
for NAMESPACE in $namespaces; do
    # Lista todas as secrets na namespace
    secrets=$(kubectl get secrets -n $NAMESPACE -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep -v NAME )

    # Loop através de cada secret
    for secret in $secrets; do
        # Obtém o nome do certificado da anotação (se existir)
        cert_name=$(kubectl get secret $secret -n $NAMESPACE  | grep -v NAME | awk '{print $1}')

        # Verifica se o secret possui um certificado TLS
        if [ ! -z "$cert_name" ]; then
            # Obtém os dados da secret
            secret_data=$(kubectl get secret $secret -n $NAMESPACE -o=jsonpath='{.data}')

            # Loop através de cada chave na secret
            for key in $(echo $secret_data | jq -r 'keys[]'); do
                # Verifica se o valor da chave é um certificado
                if echo "$key" | grep -q ".crt"; then
                    # Obtém o certificado e decodifica (se base64)
                    cert=$(echo "$secret_data" | jq -r ".\"$key\"" | base64 -d 2>/dev/null)

                    # Obtém a data de validade do certificado
                    expiration_date=$(echo "$cert" | openssl x509 -noout -enddate | cut -d= -f2)

                    # Escreve as informações do certificado no arquivo de saída
                    echo -e "$NAMESPACE\t$cert_name\t$expiration_date"  >> "$output_file"
                fi
            done
        fi
    done
done

column -t -s $'\t' $output_file | grep 2024