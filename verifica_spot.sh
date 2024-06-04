#!/bin/bash

# Definir os clusters, assinaturas e grupos de recursos com base no ambiente
clusters=(
        "akspriv-pricing-hlg"
        "akspriv-intcomercial-hlg"
        "akspriv-feed-hlg"
        "akspriv-cupom-omni-hlg"
        "akspriv-bonificacao-hlg"
        "akspriv-adanalytics-hlg"
        "akspriv-marketplace-hlg"
    )
resource_groups=(
        "rg-pricing-app-hlg"
        "rg-intcomercial-app-hlg"
        "rg-feed-app-hlg"
        "rg-cupom-omni-app-hlg"
        "rg-bonificacao-app-hlg"
        "rg-adanalytics-app-hlg"
        "rg-marketplace-app-hlg"
    )
subscriptions=(
        "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
        "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
        "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
        "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
        "be2ab514-98fa-41a5-9a21-3d4928ee6112"
        "be2ab514-98fa-41a5-9a21-3d4928ee6112"
        "b5fe7cea-c22d-4ac6-a22b-7c740dbbe4e5"
    )

# Verifique se az CLI está instalado e configurado
if ! command -v az &> /dev/null
then
    echo "Azure CLI não está instalado. Por favor, instale a Azure CLI para continuar."
    exit 1
fi

# Verifique se o usuário está logado no Azure
if ! az account show &> /dev/null
then
    echo "Por favor, faça login na sua conta Azure."
    az login
fi

# Loop através dos clusters e suas respectivas assinaturas e grupos de recursos
for i in "${!clusters[@]}"; do
    cluster=${clusters[$i]}
    resource_group=${resource_groups[$i]}
    subscription=${subscriptions[$i]}

    echo "Processando cluster: $cluster, grupo de recursos: $resource_group, assinatura: $subscription"

    # Configurar a assinatura correta
    az account set --subscription $subscription

    # Obter a lista de node pools do cluster AKS
    node_pools=$(az aks nodepool list --resource-group $resource_group --cluster-name $cluster --query "[].{Name:name,Mode:mode}" -o json)

    # Verificar cada node pool e determinar o tipo de instância
    for row in $(echo "${node_pools}" | jq -r '.[] | @base64'); do
        _jq() {
            echo ${row} | base64 --decode | jq -r ${1}
        }

        NODEPOOL_NAME=$(_jq '.Name')
        NODEPOOL_MODE=$(_jq '.Mode')

        # Obter detalhes do node pool
        nodepool_details=$(az aks nodepool show --resource-group $resource_group --cluster-name $cluster --name $NODEPOOL_NAME --query "{Name:name,Mode:mode,ScaleSetPriority:scaleSetPriority}" -o json)

        # Determinar se o node pool é regular ou spot
        scale_set_priority=$(echo $nodepool_details | jq -r '.ScaleSetPriority')
        if [[ "$scale_set_priority" == "Spot" ]]; then
            instance_type="Spot"
        else
            instance_type="Regular"
        # Exibir informações sobre o node pool
            echo "Node Pool: $NODEPOOL_NAME"
            echo "Tipo de Instância: $instance_type"
            echo "----------------------"
        fi


    done
done
