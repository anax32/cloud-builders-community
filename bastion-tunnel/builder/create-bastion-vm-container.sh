#!/bin/sh -u

#CONTAINER_NAME=eu.gcr.io/${GOOGLE_CLOUD_PROJECT}/private-deploy-proxy
CONTAINER_NAME=vimagick/privoxy

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
    --tags ${BASTION_TAGS:-"bastion-vm"}
