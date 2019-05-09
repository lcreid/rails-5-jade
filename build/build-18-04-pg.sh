#!/bin/bash
sleep 30
set -e

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
sudo -u postgres psql -c "create role ubuntu with superuser createdb login password 'ubuntu';"
# Install Redis
sudo apt-get install -y -q redis redis-tools
sudo sed -i.original \
  -e '/^supervised no/s/no/systemd/' \
  -e '/^dir/s;.*;dir /var/lib/redis;' \
  /etc/redis/redis.conf

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
sudo gem install rails -v 5.2.2 --no-document
