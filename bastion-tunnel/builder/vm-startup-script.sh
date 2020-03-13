#! /bin/bash -u

#
# self deleting vm without gcloud
#
# https://cloud.google.com/community/tutorials/create-a-self-deleting-virtual-machine

# we can't call gcloud commands directly because the gcloud-sdk install time
# is too high; so run the curl command directly with variables set from the cloudbuild
# environment via envsubst

# rather than set the envvars in the script, we set them via envsubst in the caller and
# pass the script through with variables replaced; this avoids passing variables into
# the VM, but obviously the values are still communicated...

export HEADER="Authorization: Bearer ${OAUTH_TOKEN}"
export URI="https://compute.googleapis.com/compute/v1/projects/${GOOGLE_CLOUD_PROJECT}/zones/${ZONE}/instances/${BASTION_NAME}"

# run the command in a subshell and return immediately, otherwise the host machine
# doesn't run the konlet container and get on with the job.
nohup ( sleep 260s; curl -s -H ${HEADER} -X DELETE ${URI} ) & disown
