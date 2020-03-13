FROM gcr.io/cloud-builders/gke-deploy

RUN apk add --update \
      gettext \
      openssl \
      jq \
    && \
    rm -rf /var/cache/apk/*

COPY create-bastion-vm-container.sh /usr/local/bin/create-bastion-vm.sh
COPY delete-bastion-vm.sh /usr/local/bin/delete-bastion-vm.sh
COPY vm-startup-script.sh /usr/local/bin/vm-startup-script.sh
COPY private-deploy.sh /private-deploy

ENTRYPOINT ["/private-deploy"]
