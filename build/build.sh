#!/bin/bash

# Everything is in one file because it has to get uploaded to the box to run.
# It's arguably more convenient to use when it's all in one file anyway.
# The defaults should build a Vagrant box with the current OS and Postgres,
# because that's what our Packer expects.

set -e

# Get O/S info
. /etc/os-release

# options
appliance=1
client=0
database=pg
nginx=0
os_version=$VERSION_ID
target=vagrant

usage() {
  echo "Install prerequsites for hosting Rails applications on an Ubuntu server."
  echo usage: `basename $0` [-c -d DATABASE -h -o OS_VERSION -ps -t TARGET ]
  cat <<EOF
  -c            Client-only database (typically for production-like servers).
  -d DATABASE   Specify database. Currently only default "pg".
  -h            This help.
  -n            Install Nginx and Certbot.
  -o OS_VERSION Ubuntu major and minor version. Default: The installed version.
  -s            Install for a server (no need to minimize size like for an appliance).
  -t TARGET     Deploy to a target type. Default "vagrant". -t server for one-time builds.
EOF
}

while getopts cd:hno:st: x ; do
  case $x in
    c)  client=1;;
    d)  database=$OPTARG;;
    h)  usage; exit 0;;
    n)  nginx=1;;
    o)  os_version=$OPTARG;;
    s)  appliance=0;;
    t)  target=$OPTARG;;
    \?) echo Invalid option: -$OPTARG
        usage
        exit 1;;
  esac
done
shift $((OPTIND-1))

# ./update.sh
sudo apt-get update -y -qq
sudo apt-get install -y -q linux-headers-generic
sudo apt-get install -y -q build-essential autogen autoconf libtool
sudo apt-get install -y -q ruby sqlite3 libsqlite3-dev ruby-dev

if [[ $target = vagrant ]]; then
  # ./build-vagrant.sh
  # Set up insecure key (standard Vagrant practice)
  sudo mkdir ~ubuntu/.ssh
  sudo chmod 700 ~ubuntu/.ssh
  sudo wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' -O ~ubuntu/.ssh/authorized_keys
  sudo chmod 600 ~ubuntu/.ssh/authorized_keys
  sudo chown -R ubuntu:ubuntu ~ubuntu/.ssh

  sudo apt-get install -y -q dkms virtualbox-guest-utils virtualbox-guest-dkms
fi

if [[ $database = pg ]]; then
  if [[ $client = 0 ]]; then
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
  else
    # ./build-pg-client.sh
    # Install postgres client only
    sudo apt-get install -y -q postgresql-client libpq-dev
  fi
fi

# ./build-jekyll.sh
sudo gem install jekyll --no-document

# ./build-prerequisites.sh
# Nokogiri build dependencies (from http://www.nokogiri.org/tutorials/installing_nokogiri.html#ubuntu___debian)
sudo apt-get install -y -q patch zlib1g-dev liblzma-dev


case $os_version in
  18.04)
    # Node
    sudo apt install -y -q nodejs

    # Redis
    sudo apt-get install -y -q redis redis-tools
    sudo sed -i.original \
      -e '/^supervised no/s/no/systemd/' \
      -e '/^dir/s;.*;dir /var/lib/redis;' \
      /etc/redis/redis.conf
    ;;
  16.04)
    # Node (from https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions)
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install -y -q nodejs

    # Redis
    # Adapted from: https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-redis-on-ubuntu-16-04
    # make test hangs on 4.0. Internet suggests: `taskset -c 1 make test`
    # https://github.com/antirez/redis/issues/1417
    # But above obviously doesn't work on single CPU Vagrant box.
    # 3.2 passed test at least once.
    # The version in the Ubuntu 16.04 repository is quite old (2.3)
    # At the time of writing, the most recent version of 3 was 3.2,
    # and 4.0 was already in use.
    cd /tmp
    sudo apt-get install -y -q tcl
    curl -O http://download.redis.io/releases/redis-3.2.11.tar.gz
    tar -xzvf redis-3.2.11.tar.gz
    cd redis-3.2.11
    make
    sudo make install
    sudo adduser --system --group --no-create-home redis
    sudo mkdir /var/lib/redis #/var/log/redis
    sudo chown redis:redis /var/lib/redis #/var/log/redis
    sudo chmod 770 /var/lib/redis #/var/log/redis
    sudo sed -i.original \
      -e '/^supervised no/s/no/systemd/' \
      -e '/^dir/s;.*;dir /var/lib/redis;' \
      redis.conf
    sudo cp redis.conf /etc
    cat >redis.service <<-EOF
    [Unit]
    Description=Redis In-Memory Data Store
    After=network.target
    [Service]
    User=redis
    Group=redis
    ExecStart=/usr/local/bin/redis-server /etc/redis.conf
    ExecStop=/usr/local/bin/redis-cli shutdown
    Restart=always
    [Install]
    WantedBy=multi-user.target
EOF
    sudo cp redis.service /etc/systemd/system/
    echo This build does NOT start Redis.
    echo To enable automatic start of Redis on system start, type:
    echo sudo systemctl enable redis
    cd ..

    # PDF Tool Kit
    # Appears not to be available on 18.04
    sudo apt-get install -y -q pdftk
    ;;
  *)
    echo "Unknown Ubuntu version $(os_version)."
    exit 1
    ;;
esac

# Yarn
# Has to be after the above, because 16.04 needs a new version of node.
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" |
  sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get -y -qq update
sudo apt-get install -y -q yarn

# GraphViz support for Rails ERD http://voormedia.github.io/rails-erd/install.html
sudo apt-get install -y -q graphviz

# Sendmail
sudo apt-get install -y -q sendmail

# Nginx
# Includes Certbot
if [[ $nginx = 1 ]]; then
  sudo apt-get install -y -q nginx

  # Set up for TLS (SSL) by installing certbot
  # https://certbot.eff.org/#ubuntuxenial-nginx
  # Uses Let's Encrypt certificates
  # https://letsencrypt.org/
  sudo add-apt-repository ppa:certbot/certbot -y
  sudo apt-get update -y -qq
  sudo apt-get install certbot -y -qq
  # End set-up for TLS
fi

# Bundler version must match the version on the target production box.
sudo gem install bundler -v 2.0.1 --no-document
sudo gem install rails -v 6.0.0.rc1 --no-document

# ./clean-up.sh
sudo apt-get update -y -q
# You have to do both types of upgrade explicitly.
sudo apt-get upgrade -y -q
sudo apt-get dist-upgrade -y -q
sudo apt-get autoremove -y -q

history -c && history -w

if [[ $appliance = 1 || $target = vagrant ]]; then
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

  sudo sync
fi
