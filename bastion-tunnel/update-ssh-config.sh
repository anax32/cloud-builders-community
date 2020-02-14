#! /bin/bash -u

sudo sed -i -e 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo service sshd restart
