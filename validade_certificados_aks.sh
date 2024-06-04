#!/bin/bash


if [ "$1" == "prd" ];
 then
clusters=(
    "akspriv-pricing-prd-admin"
    "akspriv-intcomercial-prd-admin"
    "akspriv-feed-prd-admin"
    "akspriv-cupom-omni-prd-admin"
    "akspriv-bonificacao-prd-admin"
    "akspriv-adanalytics-prd-admin"
    "akspriv-ferrpromo-prd-admin"
    "akspriv-mktplacecarrinho-prd-admin"
)
else
clusters=(
    "akspriv-pricing-hlg-admin"
    "akspriv-intcomercial-hlg-admin"
    "akspriv-feed-hlg-admin"
    "akspriv-cupom-omni-hlg-admin"
    "akspriv-bonificacao-hlg-admin"
    "akspriv-adanalytics-hlg-admin"
    "akspriv-marketplace-hlg-admin"

)
fi

for cluster in "${clusters[@]}"; do

    kubectx "$cluster"

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
                    echo -e "$NAMESPACE\t$cert_name\t$expiration_date"  | grep 2024 | column -t -s $'\t'
                fi
            done
        fi
    done
done
done
