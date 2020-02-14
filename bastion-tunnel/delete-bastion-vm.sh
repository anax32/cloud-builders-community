#!/bin/sh -u

# delete the bastion machine
gcloud compute \
  instances delete \
  ${BASTION_NAME} \
  --project ${GOOGLE_CLOUD_PROJECT} \
  --zone ${ZONE} \
  --quiet
