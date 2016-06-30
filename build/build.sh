#!/bin/bash

# This should be treated as notes, rather than a single script.
# There are a number of places where it's convenient to

sudo apt-get install openssh-server linux-headers-$(uname -r) build-essential dkms
# Now: Set up the insecure key according to the instructions at:
# https://www.vagrantup.com/docs/boxes/base.html, about half way down the page
# Also, do the other instructions to allow vagrant to sudo without a password
# Restart the guest
sudo mount /dev/cdrom /media/cdrom
sudo /media/cdrom/VBoxLinuxAdditions.run
# Restart the guest
# Checkpoint the VM now that the base OS and tools are ready.
sudo apt-get install ruby sqlite3 libsqlite3-dev ruby-dev
sudo gem install jekyll
# Nokogiri build dependencies (from http://www.nokogiri.org/tutorials/installing_nokogiri.html#ubuntu___debian)
sudo apt-get install patch zlib1g-dev liblzma-dev
# Install Node (from https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions)
curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
sudo apt-get install -y nodejs
# Install Postgres
apt-get install postgresql-9.5 postgresql-server-dev-9.5
sudo gem install pg
# Need the following if you're going to build webkit for Capybara
sudo apt-get install libqtwebkit-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x
# Clean up
sudo apt-get update; sudo apt-get dist-upgrade
sudo apt-get autoremove
# Checkpoint the VM before installing Rails because it's still beta
sudo gem install rails -v 5.0.0.rc2 --pre
