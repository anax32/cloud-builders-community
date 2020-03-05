#! /bin/bash -u

# allow root ssh access
sudo sed -i -e 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo service sshd restart

# open the kubectl port
sudo iptables -A INPUT -p tcp -m tcp --dport 6443 -j ACCEPT

# self deleting vm
# https://cloud.google.com/community/tutorials/create-a-self-deleting-virtual-machine
sleep 3600s
export NAME=$(curl -X GET http://metadata.google.internal/computeMetadata/v1/instance/name -H 'Metadata-Flavor: Google')
export ZONE=$(curl -X GET http://metadata.google.internal/computeMetadata/v1/instance/zone -H 'Metadata-Flavor: Google')
gcloud --quiet compute instances delete $NAME --zone=$ZONE
