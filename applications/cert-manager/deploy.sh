#!/bin/bash
set -e

NAMESPACE=cert-manager
CHART_VERSION=1.11.1
APPLICATION="cert-manager"
ENVIRONMENT=$(kubectl config current-context | cut -d- -f1)
DEPLOY=false
TEMPLATE=false

while getopts "dt" arg; do
  case $arg in
    d)
      echo "-d fue activado, Desplegando"
      DEPLOY=true
      ;;
    t)
      echo "-t fue activado, Generando plantilla"
      TEMPLATE=true
      ;;
    *)
      echo "Mostrando diferencias"
      ;;
  esac
done

echo "Entorno: ${ENVIRONMENT}"

if [ ${DEPLOY} == "true" ]
then
    ACTION="Actualizando"
    COMMAND="upgrade"
    FLAGS="--atomic --wait --timeout 300s --install ${APPLICATION}"
elif [ ${TEMPLATE} == true ]
then
    ACTION="Generando plantilla"
    COMMAND="template ${APPLICATION}"
    FLAGS=""
else
    ACTION="Mostrando diferencias de"
    COMMAND="diff upgrade --install ${APPLICATION}"
    FLAGS="-C 1"
fi

echo "${ACTION} ${APPLICATION} en el namespace ${NAMESPACE}..."

# Añadir repositorio de helm
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Instalar chart de cert-manager
helm ${COMMAND} \
    --namespace=${NAMESPACE} \
    ${FLAGS} \
    -f values.yaml \
    -f values.${ENVIRONMENT}.yaml \
    jetstack/cert-manager --version ${CHART_VERSION}