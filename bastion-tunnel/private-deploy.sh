#!/bin/bash -xue

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

FUNCTION=$1

if [ $FUNCTION == "prepare" ]; then
  echo "prepare doesn't need any tunnels"
  retval=$(/gke-deploy $@)
  exit $retval
fi

# else we are 'apply' or 'run'

# shift the command line along one so getopts works correctly
shift

# parse the command line
while getopts "f:c:n:l:b:k:" opt ; do
  case "$opt" in
  f) YAML_FILE="$OPTARG" ;;
  c) GKE_CLUSTER="$OPTARG" ;;
  n) NAMESPACE="$OPTARG" ;;
  l) export ZONE="$OPTARG" ;;
  \?) echo "kek-deploy nut!" ;;
  esac
done

# local variables
# VM name regex is: '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'
export BASTION_NAME=$(echo $GKE_CLUSTER"-bastion-$(echo /dev/random | md5sum | cut -d' ' -f1)" | cut -c -61)
export SSH_KEY_PATH="/builder/home/.ssh/cloudbuilder"
export PROXY_PORT=1080

# create the bastion vm
( cd /usr/local/bin ; ./create-bastion-vm.sh )

# create the ssh key for this cloudbuilder
mkdir -p $(dirname ${SSH_KEY_PATH})
ssh-keygen -t rsa -f ${SSH_KEY_PATH} -N ''

# register against the project
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
/gke-deploy $FUNCTION $@

# remove the bastion vm
( cd /usr/local/bin ; ./delete-bastion-vm.sh )

# remove the ssh key
