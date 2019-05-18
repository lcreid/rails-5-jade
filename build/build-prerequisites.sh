#!/bin/bash

# Build what is needed for all images.

set -e

# Nokogiri build dependencies (from http://www.nokogiri.org/tutorials/installing_nokogiri.html#ubuntu___debian)
sudo apt-get install -y -q patch zlib1g-dev liblzma-dev

# Node (from https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions)
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y -q nodejs

# Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" |
  sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get -y -qq update
sudo apt-get install -y -q yarn

# Redis
sudo apt-get install -y -q redis redis-tools
sudo sed -i.original \
  -e '/^supervised no/s/no/systemd/' \
  -e '/^dir/s;.*;dir /var/lib/redis;' \
  /etc/redis/redis.conf

# Sendmail
sudo apt-get install -y -q sendmail
