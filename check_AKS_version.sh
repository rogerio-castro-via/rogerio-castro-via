#!/bin/bash
# Script para mostrar na tela versão do AKS instalada
# Clusters
clusters=(
    "akspriv-mktplace-prd-admin"
    "akspriv-mktplacecarrinho-prd-admin"
    "akspriv-pricing-prd-admin"
    "akspriv-intcomercial-prd-admin"
    "akspriv-feed-prd-admin"
    "akspriv-cupom-omni-prd-admin"
    "akspriv-bonificacao-prd-admin"
    "akspriv-adanalytics-prd-admin"
    "akspriv-ferrpromo-prd-admin"
    "akspriv-pricing-hlg-admin"
    "akspriv-intcomercial-hlg-admin"
    "akspriv-feed-hlg-admin"
    "akspriv-cupom-omni-hlg-admin"
    "akspriv-bonificacao-hlg-admin"
    "akspriv-adanalytics-hlg-admin"
    "akspriv-marketplace-hlg-admin"
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
    "90e3f5d9-3731-4c45-a3f1-419fbc97f996"
    "90e3f5d9-3731-4c45-a3f1-419fbc97f996"
    "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
    "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
    "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
    "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
    "be2ab514-98fa-41a5-9a21-3d4928ee6112"
    "be2ab514-98fa-41a5-9a21-3d4928ee6112"
    "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
)

<<<<<<< HEAD
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
=======
clusters=("akspriv-pricing-hlg" "akspriv-intcomercial-hlg" "akspriv-feed-hlg" "akspriv-cupom-omni-hlg" "akspriv-bonificacao-hlg" "akspriv-adanalytics-hlg" "akspriv-mktponboarding-hlg" "akspriv-marketplace-hlg")
subscriptions=("b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "be2ab514-98fa-41a5-9a21-3d4928ee6112" "be2ab514-98fa-41a5-9a21-3d4928ee6112" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5" "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5")
resource_groups=("rg-pricing-app-hlg" "rg-intcomercial-app-hlg" "rg-feed-app-hlg" "rg-cupom-omni-app-hlg" "rg-bonificacao-app-hlg" "rg-adanalytics-app-hlg" "rg-mktponboarding-app-hlg" "rg-marketplace-app-hlg")
>>>>>>> 840ce14921b4ef465a1d2c2fdae9106109e96eed

for i in "${!clusters[@]}"; do
    az account set --subscription "${subscriptions[$i]}" &>/dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to set subscription ${subscriptions[$i]}" >&2
        continue
    else echo "Setando subscrição do cluster ${clusters[$i]} - Subscrição ${subscriptions[$i]}"
    fi

    kubectx "${clusters[$i]}" &>/dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to switch context to ${clusters[$i]}" >&2
        continue
    fi

    aks_version=$(az aks show --resource-group "${resource_groups[$i]}" --subscription "${subscriptions[$i]}" --name "${clusters[$i]}" --query kubernetesVersion -o tsv)
    if [ $? -ne 0 ]; then
        echo "Failed to get AKS version for cluster ${clusters[$i]}" >&2
        continue
    fi
    
    echo "Cluster: ${clusters[$i]}, AKS Version: $aks_version"
done
