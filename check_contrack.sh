#!/bin/bash

for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
    conntrack_value=$(kubectl node-shell $node -- cat /proc/sys/net/netfilter/nf_conntrack_max)

    if [ "$conntrack_value" != "1048576" ]; then
        echo "Node: $node precisa de correção" 
    fi

    sleep 1
done


#kubectl debug node/aks-precocb-28428774-vmss00009z  -it --image=ubuntu -- /bin/bash -c "ps -ef | grep java"