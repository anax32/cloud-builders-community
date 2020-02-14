#!/bin/bash -ue

#
# private-deploy
#  wrapper for the gke-deploy functionality.
#  creates a bastion VM
#  creates an ssh key
#  gets credentials for the gke cluster
#  creates an ssh tunnel to the cluster via the VM
#  calls gke-deploy with the params of the script
#  shuts down the bastion VM
#  removes the ssh key from the project
#
# NB: this script parses the gke-deploy parameters
#     so the user doesn't have to enter them twice.
#     This causes a tight-coupling.
#

# trim whitespace from variables
function trim()
{
  echo $(echo $1 | tr -d "[:blank:]")
}

FUNCTION=$1

if [ $FUNCTION == "prepare" ]; then
  echo "prepare doesn't need any tunnels"
  retval=$(/gke-deploy $@)
  exit 0
fi

# else we are 'apply' or 'run'

# shift the command line along one so getopts works correctly
shift

# parse the command line
while getopts "f:c:n:l:b:k:p:" opt ; do
  case "$opt" in
  f) YAML_FILE=$(trim "$OPTARG") ;;
  c) GKE_CLUSTER=$(trim "$OPTARG") ;;
  n) NAMESPACE=$(trim "$OPTARG") ;;
  l) export ZONE=$(trim "$OPTARG") ;;
  p) export GOOGLE_CLOUD_PROJECT=$(trim "$OPTARG") ;;
  \?) echo "kek-deploy nut!" ;;
  esac
done

# local variables
# VM name regex is: '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)' so create something similar
export BASTION_NAME=${GKE_CLUSTER:0:20}"-bastion-"$(openssl rand -hex 4)"-"$(openssl rand -hex 2)
export SSH_KEY_PATH="/builder/home/.ssh/cloudbuilder"
export PROXY_PORT=1080

# create the bastion machine and execute a startup script
# to set the allow-root access flag in sshconfigd
( cd /usr/local/bin ; ./create-bastion-vm.sh )

# create the ssh key for this cloudbuilder
mkdir -p $(dirname ${SSH_KEY_PATH})
ssh-keygen -q -t rsa -f ${SSH_KEY_PATH} -N ''

# register the against the project and create the ssh tunnel
gcloud compute ssh root@${BASTION_NAME} \
  --project ${GOOGLE_CLOUD_PROJECT} \
  --zone ${ZONE} \
  --ssh-key-expire-after 1h \
  --ssh-key-file ${SSH_KEY_PATH} \
  -- -D ${PROXY_PORT} -f -N

# get creds to the kubernetes cluster
gcloud container clusters get-credentials ${GKE_CLUSTER} \
  --project ${GOOGLE_CLOUD_PROJECT} \
  --zone ${ZONE} \
  --verbosity="info"

# FIXME: for some reason we have to call this here, or
#        later kubectl calls fail; maybe some initialisation
#        on first kubectl call?
kubectl config view -v 4

# export the proxy vars now
export HTTP_PROXY=socks5://localhost:${PROXY_PORT}
export HTTPS_PROXY=socks5://localhost:${PROXY_PORT}
export http_proxy=socks5://localhost:${PROXY_PORT}
export https_proxy=socks5://localhost:${PROXY_PORT}

# call the standard gke-deploy function (prepare, apply, run)
# FIXME: gke-deploy hangs here after outputting:
#  'Getting access to cluster "private-deployment-test" in "europe-west2-a"'
# missing env var?
#/gke-deploy $FUNCTION $@
# kubectl apply works:
# FIXME: use the yaml file from the output directory
kubectl apply -f ${YAML_FILE}

# unset the proxy details or gcloud won't work
unset HTTP_PROXY
unset HTTPS_PROXY
unset http_proxy
unset https_proxy

# remove the bastion vm
( cd /usr/local/bin ; ./delete-bastion-vm.sh )

# all done
