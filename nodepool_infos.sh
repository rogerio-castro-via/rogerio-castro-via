#!/bin/bash
data=$(date +%F-%H:%M)
#LISTA DOS CLUSTERSE
clusters=("akspriv-viastore-prd" "akspriv-vaivia-prd" "akspriv-pricing-prd" "akspriv-intcomercial-prd" "akspriv-feed-prd" "akspriv-cupom-omni-prd" "akspriv-bonificacao-prd" "akspriv-b2b-prd" "akspriv-adanalytics-prd" "akspriv-pricing-prd")
#SUBSCRIÇÕES
subscriptions=("9f66adb7-6721-4ca4-953e-e2b4b864803c" "819a7d8f-1b0a-4121-b7dc-d001d9f109f1" "90e3f5d9-3731-4c45-a3f1-419fbc97f996" "9f66adb7-6721-4ca4-953e-e2b4b864803c" "90e3f5d9-3731-4c45-a3f1-419fbc97f996" "90e3f5d9-3731-4c45-a3f1-419fbc97f996" "819a7d8f-1b0a-4121-b7dc-d001d9f109f1" "9f66adb7-6721-4ca4-953e-e2b4b864803c" "819a7d8f-1b0a-4121-b7dc-d001d9f109f1" "90e3f5d9-3731-4c45-a3f1-419fbc97f996")
#RESOURCE GROUPS
resource_groups=("rg-viastore-app-prd" "rg-vaivia-app-prd" "rg-pricing-app-prd" "rg-intcomercial-app-prd" "rg-feed-app-prd" "rg-cupom-omni-app-prd" "rg-bonificacao-app-prd" "rg-b2b-app-prd" "rg-adanalytics-app-prd" "rg-pricing-app-prd")

for ((i=0; i<${#clusters[@]}; i++)); do
    cluster=${clusters[i]}
    subscription=${subscriptions[i]}
    resource_group=${resource_groups[i]}
    output_file="nodepool_info_${cluster}_${data}.txt"

    # Setar a subscrição
    az account set --subscription $subscription

    # Listar node pools
    echo "Node Pools do Cluster: $cluster" >> $output_file
    az aks nodepool list --resource-group $resource_group --cluster-name $cluster --output table >> $output_file

    # Obter informações do node pool
    echo -e "\nInformações do Node Pool do Cluster: $cluster" >> $output_file
    az aks nodepool show --resource-group $resource_group --cluster-name $cluster --name NOME_DO_NODE_POOL --output table >> $output_file
done
