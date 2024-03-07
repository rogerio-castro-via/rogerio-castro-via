#!/bin/bash

pods=$(kubectl get pods | grep bahia | grep 25h |  awk '{print $1}')
for i in $pods; do
kubectl logs $i >> api-preco.log
done

