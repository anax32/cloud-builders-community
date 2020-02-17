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

function make_vm_name()
{
  echo ${1:0:20}"-bastion-"$(openssl rand -hex 4)"-"$(openssl rand -hex 2)
}

# local variables
# VM name regex is: '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)' so create something similar
export BASTION_NAME=$(make_vm_name ${GKE_CLUSTER})
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
  --zone ${ZONE}

# FIXME: for some reason we have to call this here, or
#        later kubectl calls fail; maybe some initialisation
#        on first kubectl call?
# redirect to dev null because keys
kubectl config view -v 4 > /dev/null

# export the proxy vars now
export HTTP_PROXY=socks5://localhost:${PROXY_PORT}
export HTTPS_PROXY=socks5://localhost:${PROXY_PORT}
export http_proxy=socks5://localhost:${PROXY_PORT}
export https_proxy=socks5://localhost:${PROXY_PORT}

# NB: gke-deploy hangs if gcloud commands are executed because the
# metadata server rejects proxied requests, so use kubectl directly
# call kubectl with the command args directly
kubectl $@

# unset the proxy details or gcloud won't work
unset HTTP_PROXY
unset HTTPS_PROXY
unset http_proxy
unset https_proxy

# remove the bastion vm
( cd /usr/local/bin ; ./delete-bastion-vm.sh )

# all done
