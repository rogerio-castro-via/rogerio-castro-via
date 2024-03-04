#!/bin/bash

# Função para exibir o uso do script
usage() {
    echo "Usage: $0 <environment>"
    echo "Environment: prd | hlg"
    exit 1
}

# Verificar se o número de argumentos é válido
if [ $# -ne 1 ]; then
    usage
fi

environment="$1"

case $environment in
    "prd")
        clusters=("akspriv-pricing-prd-admin" "akspriv-intcomercial-prd-admin" "akspriv-b2b-prd-admin" "akspriv-vaivia-prd-admin" "akspriv-viastore-prd-admin" "akspriv-feed-prd-admin" "akspriv-adanalytics-prd-admin" "akspriv-cupom-omni-prd-admin" "akspriv-bonificacao-prd-admin")
        ;;
    "hlg")
        clusters=("akspriv-pricing-hlg-admin" "akspriv-intcomercial-hlg-admin" "akspriv-b2b-hlg-admin" "akspriv-vaivia-hlg-admin" "akspriv-viastore-hlg-admin" "akspriv-feed-hlg-admin" "akspriv-adanalytics-hlg-admin" "akspriv-cupom-omni-hlg-admin" "akspriv-bonificacao-hlg-admin")
        ;;
    *)
        echo "Invalid environment. Please specify 'prd' or 'hlg'."
        usage
        ;;
esac

# Loop pelos clusters
for cluster in "${clusters[@]}"; do
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

  # Verificar se é o cluster akspriv-pricing-prd-admin para as namespaces adicionais
  if [ "$cluster" == "akspriv-pricing-prd-admin" ]; then
    ingress_nginx_oferta=$(kubectl get deploy -o wide -n ingress-nginx-oferta | grep -v IMAGES | awk '{print $7}' | cut -d "/" -f3 | cut -d ":" -f2)
    ingress_nginx_preco=$(kubectl get deploy -o wide -n ingress-nginx-preco | grep -v IMAGES | awk '{print $7}' | cut -d "/" -f3 | cut -d ":" -f2)

    echo "O cluster $cluster tem o ingress na versão $ingress_nginx_oferta na namespace ingress-nginx-oferta"
    echo "O cluster $cluster tem o ingress na versão $ingress_nginx_preco na namespace ingress-nginx-preco"
  fi
  
  echo "================================================================================================================"
done
