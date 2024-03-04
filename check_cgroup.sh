#!/bin/bash

# Loop através de cada nó
for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
    echo "Node: $node"
    
    # Executa o comando 'stat' no diretório '/sys/fs/cgroup/' do nó
    filesystem=$(kubectl node-shell "$node" -- stat -fc %T /sys/fs/cgroup/ 2>/dev/null)
    
    # Verifica se o tipo de sistema de arquivos é 'tmpfs'
    if [[ "$filesystem" != "tmpfs" ]]; then
        #echo " a versão do cgrupo no node$node é $filesystem"
        echo "Atenção: O nó $node precisa de correção da versão do  cgroup"
    fi
done
