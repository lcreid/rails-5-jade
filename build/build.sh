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
sudo apt-get install -y -q build-essential dkms autogen autoconf libtool
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
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y -q nodejs
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" |
  sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get -y -qq update
sudo apt-get install -y -q yarn
# Install Postgres
sudo apt-get install -y -q postgresql postgresql-server-dev-all
sudo gem install pg --no-document
# Leave the `pg` role for backwards compatibility.
sudo -u postgres psql -c "create role pg with superuser createdb login password 'pg';"
sudo -u postgres psql -c "create role vagrant with superuser createdb login password 'vagrant';"
# Install Redis
sudo apt-get install -y -q redis redis-tools
# The version in the Ubuntu 16.04 repository is quite old (3.0)
# At the time of writing, the most recent version of 3 was 3.2,
# and 4.0 was already in use.
# Adapted from: https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-redis-on-ubuntu-16-04
# sudo apt-get install -y -q tcl
# curl -O http://download.redis.io/releases/redis-3.2.11.tar.gz
# tar -xzvf redis-3.2.11.tar.gz
# cd redis-3.2.11
# curl -O http://download.redis.io/redis-stable.tar.gz
# tar -xzvf redis-stable.tar.gz
# cd redis-stable
# make
# sudo make install
# sudo adduser --system --group --no-create-home redis
# sudo mkdir /var/lib/redis /var/log/redis
# sudo chown redis:redis /var/lib/redis /var/log/redis
# sudo chmod 770 /var/lib/redis /var/log/redis
sudo sed -i.original \
  -e '/^supervised no/s/no/systemd/' \
  -e '/^dir/s;.*;dir /var/lib/redis;' \
  /etc/redis/redis.conf
# sudo cp redis.conf /etc
# cat >redis.service <<EOF
# [Unit]
# Description=Redis In-Memory Data Store
# After=network.target
#
# [Service]
# User=redis
# Group=redis
# ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
# ExecStop=/usr/local/bin/redis-cli shutdown
# Restart=always
#
# [Install]
# WantedBy=multi-user.target
# EOF
# sudo cp redis.service /etc/systemd/system/
# make test hangs on 4.0. Internet suggests: `taskset -c 1 make test`
# https://github.com/antirez/redis/issues/1417
# But above obviously doesn't work on single CPU Vagrant box.
# 3.2 passed test at least once.
# cd ..
# Sendmail
sudo apt-get install -y -q sendmail

# Install Chrome because the world is moving to headless Chrome.
# From: https://askubuntu.com/a/510186/264753
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt-get -y -q update
sudo apt-get -y -q install google-chrome-stable

# Need the following if you're going to build webkit for Capybara
sudo apt-get install -y -q libqtwebkit-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x xvfb

# PhantomJS is going away, but leave it in for a while to support transition
# to headless Chrome.
# Issue #13 Install phantomjs to support Poltergeist, instead of Webkit
# The one from the the Ubuntu repository is too old and has a core dump
wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
tar -xjf phantomjs-2.1.1-linux-x86_64.tar.bz2
sudo cp -a phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/bin
sudo chown root:root /usr/bin/phantomjs
rm -r phantomjs-2.1.1-linux-x86_64 phantomjs-2.1.1-linux-x86_64.tar.bz2
sudo gem install poltergeist --no-document
# Install support for Rails ERD http://voormedia.github.io/rails-erd/install.html
sudo apt-get -y -q install graphviz

# Clean up
sudo apt-get update -y -q
# You have to do both types of upgrade explicitly.
sudo apt-get upgrade -y -q
sudo apt-get dist-upgrade -y -q
sudo apt-get autoremove -y -q

# Bundler version must match the version on the target production box.
sudo gem install bundler -v 1.17.3 --no-document
sudo gem install rails -v 5.2.1 --no-document
