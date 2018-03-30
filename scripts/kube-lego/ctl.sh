#!/usr/bin/env bash

set -e

! read -rd '' HELP_STRING <<"EOF"
Usage: ctl.sh [OPTION]... --email GITLAB_URL 
Install kube-lego to Kubernetes cluster.
Mandatory arguments:
  -i, --install                install in kube-lego namespace 
  -u, --upgrade                upgrade existing installation
  -d, --delete                 remove everything, including the namespace
Optional arguments:
      --email                  admin@base.domain
  -h, --help                   output this message
EOF
DEF_KUBE_LEGO_EMAIL='admin@base.domain'
RANDOM_NUMBER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
TMP_DIR="/tmp/kube-lego-$RANDOM_NUMBER"
WORKDIR="$TMP_DIR/lego"

if [ -z "${KUBECONFIG}" ]; then
    export KUBECONFIG=~/.kube/config
fi

FIRST_INSTALL="true"

TEMP=$(getopt -o i,u,d,h --long install,upgrade,delete,email:,help \
             -n 'ctl.sh' -- "$@")

eval set -- "$TEMP"

while true; do
  case "$1" in
    -i | --install )
      MODE=install; shift ;;
    -u | --upgrade )
      MODE=upgrade; shift ;;
    -d | --delete )
      MODE=delete; shift ;;
    --email )
      KUBE_LEGO_EMAIL="$2"; shift 2;;
    -h | --help )
      echo "$HELP_STRING"; exit 0 ;;
    -- )
      shift; break ;;
    * )
      break ;;
  esac
done
if [ -z "${MODE}" ]; then
  echo "$HELP_STRING"; exit 1
fi
type git >/dev/null 2>&1 || { echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }
type kubectl >/dev/null 2>&1 || { echo >&2 "I require kubectl but it's not installed.  Aborting."; exit 1; }
type jq >/dev/null 2>&1 || { echo >&2 "I require jq but it's not installed.  Aborting."; exit 1; }


mkdir -p "$TMP_DIR"
cd "$TMP_DIR"
git clone --depth 1 https://github.com/AndrewKoryakin/lego.git

cd "$WORKDIR"
KUBE_SYSTEM=$(kubectl get node -l node-role/system -o name |wc -l)

function install {
  if [ -z "$KUBE_LEGO_EMAIL" ]; then
    KUBE_LEGO_EMAIL=$DEF_KUBE_LEGO_EMAIL
  fi
  sed -i -e "s%##EMAIL##%$KUBE_LEGO_EMAIL%g" manifests/kube-lego.yaml
  if [[ $KUBE_SYSTEM -gt 0 ]]; then
    sed -i -e "s%##AFFINITY##%%g" manifests/kube-lego.yaml
  else
    sed -i -e "s%##AFFINITY##.*%%g" manifests/kube-lego.yaml
  fi
  kubectl apply -Rf manifests/
}

function upgrade {
  if $(kubectl get deployment  kube-lego -n kube-lego > /dev/null 2>/dev/null); then
    OLD_EMAIL=$(kubectl get cm kube-lego -n kube-lego -o json | jq '.data."lego.email"')
  else
    echo "Can't upgrade. Deployment kube-lego does not exists. " && exit 1
  fi
  if [ -z "$KUBE_LEGO_EMAIL" ]; then
    KUBE_LEGO_EMAIL=$OLD_EMAIL
  fi
  sed -i -e "s%\"##EMAIL##\"%$KUBE_LEGO_EMAIL%g" manifests/kube-lego.yaml
  if [[ $KUBE_SYSTEM -gt 0 ]]; then
    sed -i -e "s%##AFFINITY##%%g" manifests/kube-lego.yaml
  else
    sed -i -e "s%##AFFINITY##.*%%g" manifests/kube-lego.yaml
  fi

  kubectl delete clusterrolebinding lego ||true
  kubectl delete svc kube-lego-nginx -nkube-lego ||true
  kubectl apply -Rf manifests/
}

if [ "$MODE" == "install" ]
then
  kubectl get deployment kube-lego -n kube-lego >/dev/null 2>&1 && FIRST_INSTALL="false"
  if [ "$FIRST_INSTALL" == "true" ]
  then
    install
  else
    echo "Deployment kube-lego exists. Please, delete or run with the --upgrade option it to avoid shooting yourself in the foot."
  fi
elif [ "$MODE" == "upgrade" ]
then
  upgrade
elif [ "$MODE" == "delete" ]
then
  kubectl delete clusterrole lego ||true
  kubectl delete clusterrolebinding lego ||true
  kubectl delete ns kube-lego || true
fi

function cleanup {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

