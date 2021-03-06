#!/bin/sh -u

# create the bastion machine and execute a startup script
# which sets the allow-root access flag in sshconfigd
gcloud compute instances create \
  ${BASTION_NAME} \
  --project ${GOOGLE_CLOUD_PROJECT} \
  --zone ${ZONE} \
  --machine-type ${MACHINE_TYPE:-"f1-micro"} \
  --subnet ${SUBNET:-"default"} \
  --metadata-from-file \
      startup-script=vm-startup-script.sh \
  --labels ${BASTION_LABELS:-"type=bastion-vm"} \
  --tags ${BASTION_TAGS:-"bastion-vm"}
