import subprocess
import base64
import json
import datetime

# Define o formato da data e hora para o nome do arquivo
date_format = "%Y-%m-%d_%H-%M-%S"
# Obtém a data e hora atual
current_datetime = datetime.datetime.now().strftime(date_format)
# Nome do arquivo com base na data e hora atual
output_file = f"certificates_check_{current_datetime}.txt"

# Lista todas as namespaces no cluster
namespaces = subprocess.run(["kubectl", "get", "namespaces", "-o", "json"],
                            capture_output=True, text=True).stdout
namespaces = json.loads(namespaces)["items"]

# Abre o arquivo de saída para escrita
with open(output_file, "w") as f:
    # Loop através de cada namespace
    for ns in namespaces:
        namespace = ns["metadata"]["name"]

        # Lista todas as secrets na namespace
        secrets = subprocess.run(["kubectl", "get", "secrets", "-n", namespace, "-o", "json"],
                                 capture_output=True, text=True).stdout
        secrets = json.loads(secrets)["items"]

        # Loop através de cada secret
        for secret in secrets:
            secret_name = secret["metadata"]["name"]

            # Obtém os dados da secret
            secret_data = secret["data"]

            # Loop através de cada chave na secret
            for key, value in secret_data.items():
                # Verifica se o valor da chave é um certificado
                if ".crt" in key:
                    # Obtém o certificado e decodifica (se base64)
                    cert = base64.b64decode(value).decode("utf-8")

                    # Obtém a data de validade do certificado
                    expiration_date = subprocess.run(["openssl", "x509", "-noout", "-enddate"],
                                                     input=cert.encode("utf-8"), capture_output=True, text=True).stdout
                    expiration_date = expiration_date.split("=")[1].strip()

                    # Escreve as informações do certificado no arquivo de saída
                    f.write(f"{namespace}\t{secret_name}\t{key}\t{expiration_date}\n")

print("Verificação de certificados concluída. Resultados salvos em:", output_file)
