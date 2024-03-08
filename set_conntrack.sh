#!/bin/bash
# O script visa ajustar o valor do conntrack somente nos nodes dos ingress.
nodes=$(kubectl get nodes  | grep -E 'aks-ingprecov2|aks-ingressv2' | awk '{print $1}')
for i in $nodes; do 
    echo "Node: $i"

    #kubectl node-shell  $i  -- sysctl -w net.netfilter.nf_conntrack_max=1048576
done
