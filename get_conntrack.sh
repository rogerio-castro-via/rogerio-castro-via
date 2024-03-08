#!/bin/bash

for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
    conntrack_value=$(kubectl node-shell $node -- cat /proc/sys/net/netfilter/nf_conntrack_max)

    echo "$conntrack_value"

    sleep 1
done
