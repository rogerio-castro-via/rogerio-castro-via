#!/bin/bash

# Definir os clusters, assinaturas e grupos de recursos com base no ambiente
if [ "$1" == "prd" ]; then
    clusters=("akspriv-viastore-prd" "akspriv-vaivia-prd" "akspriv-pricing-prd" "akspriv-intcomercial-prd" "akspriv-feed-prd" "akspriv-cupom-omni-prd" "akspriv-bonificacao-prd" "akspriv-b2b-prd" "akspriv-adanalytics-prd" "akspriv-pricing-prd")
    subscriptions=("9f66adb7-6721-4ca4-953e-e2b4b864803c" "819a7d8f-1b0a-4121-b7dc-d001d9f109f1" "90e3f5d9-3731-4c45-a3f1-419fbc97f996" "9f66adb7-6721-4ca4-953e-e2b4b864803c" "90e3f5d9-3731-4c45-a3f1-419fbc97f996" "90e3f5d9-3731-4c45-a3f1-419fbc97f996" "819a7d8f-1b0a-4121-b7dc-d001d9f109f1" "9f66adb7-6721-4ca4-953e-e2b4b864803c" "819a7d8f-1b0a-4121-b7dc-d001d9f109f1" "90e3f5d9-3731-4c45-a3f1-419fbc97f996")
    resource_groups=("rg-viastore-app-prd" "rg-vaivia-app-prd" "rg-pricing-app-prd" "rg-intcomercial-app-prd" "rg-feed-app-prd" "rg-cupom-omni-app-prd" "rg-bonificacao-app-prd" "rg-b2b-app-prd" "rg-adanalytics-app-prd" "rg-pricing-app-prd")
elif [ "$1" == "hlg" ]; then
    clusters=("akspriv-viastore-hlg" "akspriv-vaivia-hlg" "akspriv-pricing-hlg" "akspriv-intcomercial-hlg" "akspriv-feed-hlg" "akspriv-cupom-omni-hlg" "akspriv-bonificacao-hlg" "akspriv-b2b-hlg" "akspriv-adanalytics-hlg" "akspriv-pricing-hlg")
    subscriptions=("b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "be2ab514-98fa-41a5-9a21-3d4928ee6112" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "be2ab514-98fa-41a5-9a21-3d4928ee6112" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "be2ab514-98fa-41a5-9a21-3d4928ee6112" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5")
    resource_groups=("rg-viastore-app-hlg" "rg-vaivia-app-hlg" "rg-pricing-app-hlg" "rg-intcomercial-app-hlg" "rg-feed-app-hlg" "rg-cupom-omni-app-hlg" "rg-bonificacao-app-hlg" "rg-b2b-app-hlg" "rg-adanalytics-app-hlg" "rg-pricing-app-hlg")
else
    echo "Ambiente inválido. Deve ser 'prd' ou 'hlg'."
    exit 1
fi

# Iterar sobre os clusters
for i in "${!clusters[@]}"
do
    cluster="${clusters[i]}"
    subscription="${subscriptions[i]}"
    resource_group="${resource_groups[i]}"
    
    echo "Cluster: $cluster"
    echo "Subscription: $subscription"
    echo "Resource Group: $resource_group"
    
    # Obter a versão do AKS do cluster
    aks_version=$(az aks show --resource-group "$resource_group" --subscription "$subscription" --name "$cluster" --query kubernetesVersion -o tsv)
    
    if [ -n "$aks_version" ]; then
        echo "Versão do AKS do cluster: $aks_version"
    else
        echo "Erro ao obter a versão do AKS para o cluster $cluster"
    fi
    
    echo "Nodepools:"
    
    # Obter os nodepools do cluster
    nodepools=$(az aks nodepool list --resource-group "$resource_group" --subscription "$subscription" --cluster-name "$cluster" --query '[].name' -o tsv)
    
    # Iterar sobre os nodepools
    while IFS= read -r nodepool; do
        echo "Nodepool: $nodepool"
        # Obter a versão do AKS para o nodepool
        nodepool_aks_version=$(az aks nodepool show --resource-group "$resource_group" --subscription "$subscription" --cluster-name "$cluster" --name "$nodepool" -o tsv | awk '{print $5}')
        
        if [ -n "$nodepool_aks_version" ]; then
            echo "Versão do AKS do nodepool $nodepool: $nodepool_aks_version"
        else
            echo "Erro ao obter a versão do AKS para o nodepool $nodepool do cluster $cluster"
        fi
    done <<< "$nodepools"
    
    echo "-----------------------------------------"
done
