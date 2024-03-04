#!/bin/bash

# Função para exibir o uso do script
usage() {
    echo "Usage: $0 <cluster_name>"
    exit 1
}

# Verificar se o número de argumentos é válido
if [ $# -ne 1 ]; then
    usage
fi

# Nome do cluster passado como argumento
cluster="$1"

# Verificar o nome do cluster usando case
case $cluster in
    "akspriv-pricing-prd-admin"|"akspriv-intcomercial-prd-admin"|"akspriv-b2b-prd-admin"|"akspriv-vaivia-prd-admin"|"akspriv-viastore-prd-admin"|"akspriv-feed-prd-admin"|"akspriv-adanalytics-prd-admin"|"akspriv-cupom-omni-prd-admin"|"akspriv-bonificacao-prd-admin")
        ;;
    *)
        echo "Cluster '$cluster' não reconhecido."
        usage
        ;;
esac

#az login

echo "Cluster: $cluster"

# Autenticar-se no cluster AKS
kubectx "$cluster" > /dev/null

# Esperar 1 segundo após autenticação
sleep 1

# Obtém lista dos deployments dos ingress
ingress_nginx=$(kubectl get deploy -o wide -n ingress-nginx | grep -v IMAGES | awk '{print $7}' | cut -d "/" -f3 | cut -d ":" -f2)
ingress_nginx_external=$(kubectl get deploy -o wide -n ingress-nginx-external | grep -v IMAGES | awk '{print $7}' | cut -d "/" -f3 | cut -d ":" -f2)

# Exibir as informações
echo "O cluster $cluster tem o ingress na versão $ingress_nginx"
echo "O cluster $cluster tem o ingress-external na versão $ingress_nginx_external"
echo "================================================================================================================"
