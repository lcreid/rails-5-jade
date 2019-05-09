#!/bin/bash
set -e

# Set up insecure key (standard Vagrant practice)
sudo mkdir ~ubuntu/.ssh
sudo chmod 700 ~ubuntu/.ssh
sudo wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' -O ~ubuntu/.ssh/authorized_keys
sudo chmod 600 ~ubuntu/.ssh/authorized_keys
sudo chown -R ubuntu:ubuntu ~ubuntu/.ssh

sudo apt-get install -y -q dkms virtualbox-guest-utils virtualbox-guest-dkms
