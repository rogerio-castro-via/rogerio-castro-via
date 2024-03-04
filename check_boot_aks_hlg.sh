#!/bin/bash

clusters="akspriv-viastore-hlg-admin akspriv-vaivia-hlg-admin akspriv-pricing-hlg-admin akspriv-intcomercial-hlg-admin akspriv-feed-hlg-admin akspriv-cupom-omni-hlg-admin akspriv-bonificacao-hlg-admin akspriv-b2b-hlg-admin akspriv-adanalytics-hlg-admin akspriv-pricing-hlg-admin"

for i in $clusters; do
    kubectx "$i"
    sleep 1
    kubectl get nodes

    echo "-----------------------------"
done
