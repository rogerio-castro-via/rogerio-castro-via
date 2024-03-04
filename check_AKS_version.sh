#!/bin/bash

# Definir os nomes dos clusters

clusters=("akspriv-viastore-hlg" "akspriv-vaivia-hlg" "akspriv-pricing-hlg" "akspriv-intcomercial-hlg" "akspriv-feed-hlg" "akspriv-cupom-omni-hlg" "akspriv-bonificacao-hlg" "akspriv-b2b-hlg" "akspriv-adanalytics-hlg")
subscriptions=("b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "be2ab514-98fa-41a5-9a21-3d4928ee6112" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "be2ab514-98fa-41a5-9a21-3d4928ee6112" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "be2ab514-98fa-41a5-9a21-3d4928ee6112")
resource_groups=("rg-viastore-app-hlg" "rg-vaivia-app-hlg" "rg-pricing-app-hlg" "rg-intcomercial-app-hlg" "rg-feed-app-hlg" "rg-cupom-omni-app-hlg" "rg-bonificacao-app-hlg" "rg-b2b-app-hlg" "rg-adanalytics-app-hlg" "rg-pricing-app-hlg")

# Definir as assinaturas

# Definir os grupos de recursos

# Iterar sobre os clusters
for i in "${!clusters[@]}"
do
    cluster="${clusters[i]}"
    subscription="${subscriptions[i]}"
    resource_group="${resource_groups[i]}"
    
    echo "Cluster: $cluster"
    echo "Subscription: $subscription"
    echo "Resource Group: $resource_group"
    
    # Obter a versão do AKS
    aks_version=$(az aks show --resource-group "$resource_group" --subscription "$subscription" --name "$cluster" --query kubernetesVersion -o tsv)
    
    if [ -n "$aks_version" ]; then
        echo "Versão do AKS: $aks_version"
    else
        echo "Erro ao obter a versão do AKS para o cluster $cluster"
    fi
    
    echo "-----------------------------------------"
done
