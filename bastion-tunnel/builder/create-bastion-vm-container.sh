#!/bin/sh -u

#CONTAINER_NAME=eu.gcr.io/${GOOGLE_CLOUD_PROJECT}/private-deploy-proxy
CONTAINER_NAME=eu.gcr.io/${GOOGLE_CLOUD_PROJECT}/privoxy

(OAUTH_TOKEN=$(gcloud auth print-access-token) envsubst '${GOOGLE_CLOUD_PROJECT} ${BASTION_NAME} ${ZONE} ${OAUTH_TOKEN}' < vm-startup-script.sh > tmp.sh)

# create the bastion machine
gcloud compute instances \
  create-with-container \
    ${BASTION_NAME} \
    --project ${GOOGLE_CLOUD_PROJECT} \
    --zone ${ZONE} \
    --machine-type ${MACHINE_TYPE:-"f1-micro"} \
    --network ${NETWORK:-"default"} \
    --subnet ${SUBNET:-"default"} \
    --container-image=${CONTAINER_NAME} \
    --container-env=CLUSTER_PRIVATE_IP=${CLUSTER_PRIVATE_IP} \
    --labels ${BASTION_LABELS:-"type=bastion-vm"} \
    --tags ${BASTION_TAGS:-"bastion-vm"} \
    --metadata-from-file \
        startup-script=tmp.sh
