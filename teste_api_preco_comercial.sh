#!/bin/bash

# URL a ser verificada
URL="https://precofretecomercial.casasbahia.com.br/health"

# Executa o curl para verificar o status da URL
response=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

# Verifica se o status é 200 (OK)
if [ "$response" -eq 200 ]; then
    echo "A URL está acessível (status 200 OK)."
else
    echo "Erro: A URL não está acessível (status $response)."
fi
