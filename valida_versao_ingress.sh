#!/bin/bash
az login
clusters=("akspriv-pricing-hlg-admin" "akspriv-intcomercial-hlg-admin" "akspriv-b2b-hlg-admin" "akspriv-vaivia-hlg-admin" "akspriv-viastore-hlg-admin" "akspriv-feed-hlg-admin" "akspriv-adanalytics-hlg-admin" "akspriv-cupom-omni-hlg-admin" "akspriv-bonificacao-hlg-admin")

## Loop pelos clusters
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
  echo "================================================================================================================"
done
