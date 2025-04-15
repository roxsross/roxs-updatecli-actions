#!/bin/bash
set -e

NAMESPACE=ingress-nginx
CHART_VERSION=4.7.1
APPLICATION="ingress-nginx"
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
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Instalar chart de ingress-nginx
helm ${COMMAND} \
    --namespace=${NAMESPACE} \
    ${FLAGS} \
    -f values.yaml \
    -f values.${ENVIRONMENT}.yaml \
    ingress-nginx/ingress-nginx --version ${CHART_VERSION}