#!/bin/bash
# Script que verifica versão do AKS em todos os servidores da jornada Capacidade de Negócios

# Clusters
clusters=(
    "akspriv-mktplace-prd"
	"akspriv-mktplacecarrinho-prd"
    "akspriv-pricing-prd"
    "akspriv-intcomercial-prd"
    "akspriv-feed-prd"
    "akspriv-cupom-omni-prd"
    "akspriv-bonificacao-prd"
    "akspriv-adanalytics-prd"
	"akspriv-ferrpromo-prd"    
    "akspriv-pricing-hlg"
    "akspriv-intcomercial-hlg"
    "akspriv-feed-hlg"
    "akspriv-cupom-omni-hlg"
    "akspriv-bonificacao-hlg"
    "akspriv-adanalytics-hlg"
    "akspriv-marketplace-hlg"
)

# Subscriptions
subscriptions=(
    "90e3f5d9-3731-4c45-a3f1-419fbc97f996"
	"9f66adb7-6721-4ca4-953e-e2b4b864803c"
    "90e3f5d9-3731-4c45-a3f1-419fbc97f996"
    "9f66adb7-6721-4ca4-953e-e2b4b864803c"
    "90e3f5d9-3731-4c45-a3f1-419fbc97f996"
    "90e3f5d9-3731-4c45-a3f1-419fbc97f996"
    "819a7d8f-1b0a-4121-b7dc-d001d9f109f1"
    "819a7d8f-1b0a-4121-b7dc-d001d9f109f1"
    "90e3f5d9-3731-4c45-a3f1-419fbc97f996"    
    "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
    "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
    "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
    "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
    "be2ab514-98fa-41a5-9a21-3d4928ee6112"
    "be2ab514-98fa-41a5-9a21-3d4928ee6112"
    "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
)

# Resource Groups
resource_groups=(
    "rg-mktplace-app-prd"    
	"rg-mktplace-app-prd"
    "rg-pricing-app-prd"
    "rg-intcomercial-app-prd"
    "rg-feed-app-prd"
    "rg-cupom-omni-app-prd"
    "rg-bonificacao-app-prd"
    "rg-adanalytics-app-prd"
	"rg-aksferrpromoprv-app-prd"    
    "rg-pricing-app-hlg"
    "rg-intcomercial-app-hlg"
    "rg-feed-app-hlg"
    "rg-cupom-omni-app-hlg"
    "rg-bonificacao-app-hlg"
    "rg-adanalytics-app-hlg"
    "rg-marketplace-app-hlg"
)

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