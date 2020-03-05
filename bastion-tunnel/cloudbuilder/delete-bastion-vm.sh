#!/bin/sh -u

# stop the bastion machine
gcloud compute instances stop \
  ${BASTION_NAME} \
  --project ${GOOGLE_CLOUD_PROJECT} \
  --zone ${ZONE} \
  --quiet

# delete the bastion machine
gcloud compute instances delete \
  ${BASTION_NAME} \
  --project ${GOOGLE_CLOUD_PROJECT} \
  --zone ${ZONE} \
  --quiet
