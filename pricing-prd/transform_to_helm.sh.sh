#!/bin/bash
 
function validate_prereqs(){
  prereqs_available=true
  kubectl help  &> /dev/null
  if [ $? -ne 0 ]
  then
    prereqs_available=false
    echo "Você precisa ter o kubectl instalado e configurado para acessar o cluster"
  fi
 
  kubectl neat help  &> /dev/null
  if [ $? -ne 0 ]
  then
    prereqs_available=false
    echo "Você precisa ter o kubectl neat instalado"
    echo "Para instalar, instale o kubectl krew (caso ainda não tenha) usando as instruções em: https://krew.sigs.k8s.io/docs/user-guide/setup/install/"
    echo "E em seguida, utilize o comando: kubectl krew install neat"
  fi
 
  if [ "$prereqs_available" = false ]
  then
    echo "ERRO! Verifique os requisitos acima"
    exit 1
  fi
}
 
function patch_artifact(){
  type=$1
  artifact=$(kubectl get $type --no-headers=true --ignore-not-found ${name} -n $namespace | awk '{print $1}')
 
  if [ -n "$artifact" ]; then
    echo "$type encontrado, salvando o backup localmente e executando patch"
    kubectl get $type --no-headers=true --ignore-not-found ${name} -n $namespace -o yaml | kubectl neat >> ${backup_file}
    echo "---" >> ${backup_file}
    kubectl patch --type='merge' -n $namespace $type $artifact -p "$patch"
  fi
}
 
function send_to_nexus(){
  echo "Enviando backup para o Nexus..."
  curl -H 'Authorization: Basic a3ViZV9hcnRpZmFjdF9iYWNrdXBfdXNlcjprdWIzQXJ0MWY0Y3RCNGNrdXBVczNy' --upload-file $backup_file "https://nexus.viavarejo.com.br/repository/workspace/backup-prd/${namespace}/${name}/${start_date}.yaml"
  if [ $? -ne 0 ]
  then
    echo "Backup salvo no Nexus."
    echo "URL do backup: https://nexus.viavarejo.com.br/repository/workspace/backup-prd/${namespace}/${name}/${start_date}.yaml"
  fi
}
 
validate_prereqs
 
read -p "Namespace: " namespace
read -p "Nome da aplicação: " name
start_date=$(date -u +"%Y%m%d-%H%M%S")
 
#this will be the directory in which the backups will be saved.
backup_file=bkp_${namespace}_${name}_${start_date}.yaml
 
patch='{"metadata":{"annotations":{"meta.helm.sh/release-name":"'$name'","meta.helm.sh/release-namespace":"'$namespace'"},"labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
 
patch_artifact deployment
patch_artifact service
patch_artifact ingress
patch_artifact configmap
patch_artifact hpa
patch_artifact secret
patch_artifact serviceaccount
 
ingress_external=$(kubectl get ingress --no-headers=true --ignore-not-found ${name}-external -n $namespace | awk '{print $1}')
if [ -n "$ingress_external" ]; then
  echo "ingress external encontrado, salvando o backup localmente e executando patch"
  kubectl get ingress --no-headers=true --ignore-not-found ${name}-external -n $namespace -o yaml | kubectl neat >> ${backup_file}
  echo "---" >> ${backup_file}
  kubectl patch --type='merge' -n $namespace ingress $ingress_external -p "$patch"
fi
 
send_to_nexus