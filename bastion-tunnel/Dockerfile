FROM gcr.io/cloud-builders/gke-deploy

ENV SSH_KEY_PATH="/builder/home/.ssh/cloudbuilder"
ENV BASTION_NAME="bastion-vm"
ENV PROXY_PORT="1080"

COPY create-bastion-vm.sh /usr/local/bin/create-bastion-vm.sh
COPY delete-bastion-vm.sh /usr/local/bin/delete-bastion-vm.sh
COPY update-ssh-config.sh /usr/local/bin/update-ssh-config.sh
COPY private-deploy.sh /private-deploy

ENTRYPOINT ["/private-deploy"]

EXPOSE $PROXY_PORT
