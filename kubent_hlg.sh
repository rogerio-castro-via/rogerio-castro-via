#!/bin/bash

# Definir os nomes dos clusters

# Definir os clusters, assinaturas e grupos de recursos com base no ambiente
if [ "$1" == "prd" ]; then
	clusters=("akspriv-pricing-prd" "akspriv-intcomercial-prd" "akspriv-feed-prd" "akspriv-cupom-omni-prd" "akspriv-bonificacao-prd" "akspriv-adanalytics-prd" "akspriv-mktponboarding-prd" "akspriv-mktplace-prd")
    subscriptions=("90E3F5D9-3731-4C45-A3F1-419FBC97F996" "9f66adb7-6721-4ca4-953e-e2b4b864803c" "90e3f5d9-3731-4c45-a3f1-419fbc97f996" "90e3f5d9-3731-4c45-a3f1-419fbc97f996" "819a7d8f-1b0a-4121-b7dc-d001d9f109f1" "819a7d8f-1b0a-4121-b7dc-d001d9f109f1" "9f66adb7-6721-4ca4-953e-e2b4b864803c" "90e3f5d9-3731-4c45-a3f1-419fbc97f996")
    resource_groups=("rg-pricing-app-prd" "rg-intcomercial-app-prd" "rg-feed-app-prd" "rg-cupom-omni-app-prd" "rg-feed-app-prd" "rg-cupom-omni-app-prd" "rg-bonificacao-app-prd" "rg-adanalytics-app-prd" "rg-mktponboarding-app-prd" "rg-mktplace-app-prd")
elif [ "$1" == "hlg" ]; then
    clusters=("akspriv-pricing-hlg" "akspriv-intcomercial-hlg" "akspriv-feed-hlg" "akspriv-cupom-omni-hlg" "akspriv-bonificacao-hlg" "akspriv-adanalytics-hlg" "akspriv-mktponboarding-hlg" "akspriv-marketplace-hlg")
	subscriptions=("b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "be2ab514-98fa-41a5-9a21-3d4928ee6112" "be2ab514-98fa-41a5-9a21-3d4928ee6112" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5")
    resource_groups=("rg-pricing-app-hlg" "rg-intcomercial-app-hlg" "rg-feed-app-hlg" "rg-cupom-omni-app-hlg" "rg-bonificacao-app-hlg" "rg-adanalytics-app-hlg" "rg-mktponboarding-app-hlg" "rg-marketplace-app-hlg")
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
    
    # Obter o nome do cluster
    cluster_name=$(az aks show --resource-group "$resource_group" --subscription "$subscription" --name "$cluster" --query name -o tsv)
        sleep 1
    kubectx "$cluster"-admin
        sleep 1
     kubent > clusters/"$cluster_name.txt"
    if [ -n "$cluster_name" ]; then
        echo "Nome do cluster: $cluster_name"
    else
        echo "Erro ao obter o nome do cluster para $cluster"
    fi
    
    echo "-----------------------------------------"
done
