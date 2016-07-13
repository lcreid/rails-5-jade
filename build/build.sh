#!/bin/bash
sleep 30

# Set up insecure key (standard Vagrant practice)
sudo mkdir ~vagrant/.ssh
sudo chmod 700 ~vagrant/.ssh
sudo wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' -O ~vagrant/.ssh/authorized_keys
sudo chmod 600 ~vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant ~vagrant/.ssh

sudo apt-get update -y -qq
sudo apt-get install -y -q virtualbox-guest-utils virtualbox-guest-dkms
sudo apt-get install -y -q linux-headers-$(uname -r) build-essential dkms
sudo apt-get install -y -q ruby sqlite3 libsqlite3-dev ruby-dev

sudo gem install jekyll
# Nokogiri build dependencies (from http://www.nokogiri.org/tutorials/installing_nokogiri.html#ubuntu___debian)
sudo apt-get install -y -q patch zlib1g-dev liblzma-dev
# Install Node (from https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions)
curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
sudo apt-get install -y -q -y nodejs
# Install Postgres
sudo apt-get install -y -q postgresql-9.5 postgresql-server-dev-9.5
sudo gem install pg
# Need phantomjs for poltergeist
sudo apt-get install -y -q phantomjs
sudo gem install poltergeist
# Install support for Rails ERD http://voormedia.github.io/rails-erd/install.html
sudo apt-get -y -q install graphviz
# Clean up
sudo apt-get dist-upgrade -y -qq
sudo apt-get autoremove -y -qq

sudo gem install rails -v 5.0.0
