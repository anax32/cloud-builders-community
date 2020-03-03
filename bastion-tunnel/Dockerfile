FROM gcr.io/cloud-builders/gke-deploy

RUN apk add --update openssl && \
    rm -rf /var/cache/apk/*

COPY create-bastion-vm.sh /usr/local/bin/create-bastion-vm.sh
COPY delete-bastion-vm.sh /usr/local/bin/delete-bastion-vm.sh
COPY private-deploy.sh /private-deploy

ENTRYPOINT ["/private-deploy"]

EXPOSE $PROXY_PORT
