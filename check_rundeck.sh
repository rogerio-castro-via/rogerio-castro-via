#!/bin/bash
export RD_URL="http://10.128.46.64:4440"
export RD_BYPASS_URL="https://rundeckmarketplace.viavarejo.com.br/"
export RD_USER="2160000641"
export RD_PASSWORD="@option.pass@"
export RD_PROJECT="MARKETPLACE"

JOBS=$(rd executions list | awk '{print $3}' | cut -c12-13|   grep -v executions)
DATA=$(date +%T | cut -c1-2)

for i in $JOBS; do
   if  [  "$i" == "$DATA" ]; then
    echo "OK"
    else
    echo "Algum job esta travado, verificar"
    exit 1
    fi
done