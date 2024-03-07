#!/bin/bash

# Lista de servidores
servers=("10.128.8.120" "10.128.8.121" "10.128.8.126" "10.128.8.127" "10.128.8.128" "10.128.8.172" "10.128.8.173" "10.128.8.174" "10.128.8.116" "10.128.8.183" "10.128.8.181" "10.128.8.219" "10.128.8.247" "10.128.8.248" "10.128.8.249")

# Dados para o curl
curl_data='{"codigoBandeira": 1,  "codigoCanalVenda": 1,  "codigoCupom": "TESTBARRAM01", "codigoFilial": 1000,  "cpf": "22063586896",  "desconto":10,  "listaFormaDePagamento": [{"cartoesDeCredito": [{"codigo": 1}],"codigoFormaDePagamento": 1}  ],  "listaSku": [{"codigoSetor": 1,"codigoSku": 4981251,"listaFormaDePagamento": [{"cartoesDeCredito": [{"codigo": 1}],"codigoFormaDePagamento": 1}],"quantidade": 1,"tipoSku": "M","valorLiquidoCompraComDesconto": 10}], "tipoDesconto": "V"}'

# Token de autorização
authorization_token='0Fl7c7j2ugARYXMszf9zy7IrjYIx0giTqWnfcgqSzV0Ptfk4vU5ywbM4tPWOF5KsUZp0G+Oo9cTxh/UxexWBSwTzQ65i0SylVT9vXgd5yJF0F0u9IOy9JA=='

# Mensagem de retorno esperada
expected_response='{"codigo":"19","descricao":"Severidade: I - Programa: MKN0025 - Tabela:  - rCode: 19 - Comando:  - Texto: CUPOM DE DESCONTO VENCIDO - SqlCode: 0","mensagem":"Severidade: I - Programa: MKN0025 - Tabela:  - rCode: 19 - Comando:  - Texto: CUPOM DE DESCONTO VENCIDO - SqlCode: 0","mensagemAmigavel":"Severidade: I - Programa: MKN0025 - Tabela:  - rCode: 19 - Comando:  - Texto: CUPOM DE DESCONTO VENCIDO - SqlCode: 0"}'

# Loop sobre os servidores
for server in "${servers[@]}"; do
    # Executar o comando curl
    response=$(curl --silent --location --request PUT "http://$server:8080/v3.1/cupom/consumo" \
    --header "Authorization: $authorization_token" \
    --header 'Content-Type: application/json' \
    --data-raw "$curl_data")

    # Verificar se a resposta é igual à esperada
    if [[ "$response" == "$expected_response" ]]; then
        echo "Servidor $server: Validado."
    else
        echo "Servidor $server: Resposta diferente do esperado."
    fi
done