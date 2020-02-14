#!/bin/sh -u

#BASTION_NAME=bastion-name-unset
#ZONE=europe-west2-a
# https://cloud.google.com/compute/docs/machine-types#n1_shared-core_machine_types
#MACHINE_TYPE=f1-micro

# create the bastion machine and execute a startup script
# to set the allow-root access flag in sshconfigd
gcloud compute \
  instances create \
  ${BASTION_NAME} \
  --project ${GOOGLE_CLOUD_PROJECT} \
  --zone ${ZONE} \
  --machine-type ${MACHINE_TYPE:-"f1-micro"} \
  --subnet ${SUBNET:-"default"} \
  --metadata-from-file \
      startup-script=update-ssh-config.sh
