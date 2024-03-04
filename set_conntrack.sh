#!/bin/bash
for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
    echo "Node: $node"

    kubectl node-shell  $node  -- sysctl -w net.netfilter.nf_conntrack_max=1048576
done
