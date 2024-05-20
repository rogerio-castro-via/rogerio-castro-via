#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Uso: $0 <nome-do-cluster>"
    exit 1
fi

kubectx "$1"

