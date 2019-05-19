#!/bin/bash

# Everything is in one file because it has to get uploaded to the box to run.

set -e
date
TZ=UTC sudo hwclock -r

# ./update.sh
sudo apt-get update -y -qq
sudo apt-get install -y -q linux-headers-generic
sudo apt-get install -y -q build-essential autogen autoconf libtool
sudo apt-get install -y -q ruby sqlite3 libsqlite3-dev ruby-dev

# ./build-vagrant.sh
# Set up insecure key (standard Vagrant practice)
sudo mkdir ~ubuntu/.ssh
sudo chmod 700 ~ubuntu/.ssh
sudo wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' -O ~ubuntu/.ssh/authorized_keys
sudo chmod 600 ~ubuntu/.ssh/authorized_keys
sudo chown -R ubuntu:ubuntu ~ubuntu/.ssh

sudo apt-get install -y -q dkms virtualbox-guest-utils virtualbox-guest-dkms

# ./build-jekyll.sh
sudo gem install jekyll --no-document

# ./build-pg.sh
# Install Postgres
# This script is useful for local development boxes where a rather obvious username
# and password are not a problem.
# Do not use this for database servers that will be exposed to a network.

sudo apt-get install -y -q postgresql postgresql-server-dev-all
# Leave the `pg` and `vagrant` roles for backwards compatibility.
sudo -u postgres psql -c "create role pg with superuser createdb login password 'pg';"
sudo -u postgres psql -c "create role vagrant with superuser createdb login password 'vagrant';"
sudo -u postgres psql -c "create role ubuntu with superuser createdb login password 'ubuntu';"

# ./build-prerequisites.sh
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

# ./clean-up.sh
sudo apt-get update -y -q
# You have to do both types of upgrade explicitly.
sudo apt-get upgrade -y -q
sudo apt-get dist-upgrade -y -q
sudo apt-get autoremove -y -q

history -c && history -w

# ./minimize.sh
# From https://github.com/chef/bento/blob/master/_common/minimize.sh
# Added sudo in the right places.

# Whiteout root
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$(($count-1))
sudo dd if=/dev/zero of=/tmp/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
sudo rm /tmp/whitespace

# Whiteout /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
count=$(($count-1))
sudo dd if=/dev/zero of=/boot/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
sudo rm /boot/whitespace

set +e
swapuuid="`/sbin/blkid -o value -l -s UUID -t TYPE=swap`";
case "$?" in
    2|0) ;;
    *) exit 1 ;;
esac
set -e

if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart="`readlink -f /dev/disk/by-uuid/$swapuuid`";
    sudo /sbin/swapoff "$swappart";
    sudo dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? is suppressed";
    sudo /sbin/mkswap -U "$swapuuid" "$swappart";
fi

sudo sync;

