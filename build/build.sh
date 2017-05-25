#!/bin/bash
sleep 30
set -e

# Set up insecure key (standard Vagrant practice)
sudo mkdir ~vagrant/.ssh
sudo chmod 700 ~vagrant/.ssh
sudo wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' -O ~vagrant/.ssh/authorized_keys
sudo chmod 600 ~vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant ~vagrant/.ssh

sudo apt-get update -y -qq
sudo apt-get install -y -q virtualbox-guest-utils virtualbox-guest-dkms
sudo apt-get install -y -q linux-headers-generic
sudo apt-get install -y -q build-essential dkms
sudo apt-get install -y -q ruby sqlite3 libsqlite3-dev ruby-dev

# rbenv install Issue #20
# sudo apt-get install -y libreadline-dev
# git clone https://github.com/rbenv/rbenv.git ~/.rbenv
# cd ~/.rbenv && src/configure && make -C src
# echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
# export PATH="$HOME/.rbenv/bin:$PATH"
# echo 'eval "$(rbenv init -)"' >> ~/.bashrc
# eval "$(rbenv init -)"
# end rbenv install

# ruby-build install
# git clone https://github.com/rbenv/ruby-build.git
# cd ruby-build
# sudo ./install.sh
# cd
# end ruby-build install

# Build default Ruby
# sudo apt-get install -y -q libssl-dev zlib1g-dev
# rbenv rehash
# rbenv install 2.4.1
# rbenv global 2.4.1
# rbenv rehash
# End build default Ruby

sudo gem install jekyll --no-document
# Nokogiri build dependencies (from http://www.nokogiri.org/tutorials/installing_nokogiri.html#ubuntu___debian)
sudo apt-get install -y -q patch zlib1g-dev liblzma-dev
# Install Node (from https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions)
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
sudo apt-get install -y -q -y nodejs
# Install Postgres
sudo apt-get install -y -q postgresql-9.5 postgresql-server-dev-9.5
sudo gem install pg --no-document
sudo -u postgres psql -c "create role pg with superuser createdb login password 'pg';"
# Sendmail
sudo apt-get install -y -q sendmail
# Need the following if you're going to build webkit for Capybara
sudo apt-get install -y -q libqtwebkit-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x xvfb
# Issue #13 Install phantomjs to support Poltergeist, instead of Webkit
# The one from the the Ubuntu repository is too old and has a core dump
wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
tar -xjf phantomjs-2.1.1-linux-x86_64.tar.bz2
sudo cp -a phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/bin
sudo chown root:root /usr/bin/phantomjs
sudo gem install poltergeist --no-document
# Install support for Rails ERD http://voormedia.github.io/rails-erd/install.html
sudo apt-get -y -q install graphviz

# Clean up
sudo apt-get update -y -q
# You have to do both types of upgrade explicitly.
sudo apt-get upgrade -y -q
sudo apt-get dist-upgrade -y -q
sudo apt-get autoremove -y -q

sudo gem install rails -v 5.1.0 --no-document
