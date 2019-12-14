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
jekyll_version=4.0
nginx=0
os_version=$VERSION_ID
rails_version=6.0.2
target=vagrant

usage() {
  echo "Install prerequsites for hosting Rails applications on an Ubuntu server."
  echo usage: `basename $0` [-c -d DATABASE -h -o OS_VERSION -ps -t TARGET ]
  cat <<EOF
  -c                Client-only database (typically for production-like servers).
  -d DATABASE       Specify database. Default "pg". Can be "mssql" or "pg".
  -h                This help.
  -j JEKYLL_VERSION Jekyll version to install.
  -n                Install Nginx and Certbot.
  -o OS_VERSION     Ubuntu major and minor version. Default: The installed version.
  -r RAILS_VERSION  Rails version to install.
  -s                Install for a server (no need to minimize size like for an appliance).
  -t TARGET         Deploy to a target type. Default "vagrant". Give "-t server" for server builds.
EOF
}

while getopts cd:hj:no:r:st: x ; do
  case $x in
    c)  client=1;;
    d)  database=$OPTARG;;
    h)  usage; exit 0;;
    j)  jekyll_version=$OPTARG;;
    n)  nginx=1;;
    o)  os_version=$OPTARG;;
    r)  rails_version=$OPTARG;;
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
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q ruby sqlite3 libsqlite3-dev ruby-dev

if [[ $target = vagrant ]]; then
  # ./build-vagrant.sh
  # Set up insecure key (standard Vagrant practice)
  sudo mkdir ~ubuntu/.ssh
  sudo chmod 700 ~ubuntu/.ssh
  sudo wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' -O ~ubuntu/.ssh/authorized_keys
  sudo chmod 600 ~ubuntu/.ssh/authorized_keys
  sudo chown -R ubuntu:ubuntu ~ubuntu/.ssh

  sudo apt-get install -y -q dkms virtualbox-guest-utils virtualbox-guest-dkms

  # https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers
  echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
fi

case $database in
  pg)
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
    ;;
  mssql)
    # So far, it looks like only the Microsoft stuff needs this:
    sudo apt-get install -y -q apt-transport-https

    # echo "Installing Microsoft key"
    # https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

    # echo "Installing MS SQL Client"
    # Client
    # Apparently the repository name hasn't changed
    sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/prod.list)"
    sudo apt-get -y -q update
    ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y -q --no-install-recommends mssql-tools unixodbc-dev
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
    # `rails dbconsole` uses `sqsh`
    sudo apt-get install -y -q sqsh

    if [[ $client = 0 ]]; then
      # echo "Installing MS SQL Server"
      # Server
      # Apparently the repository name hasn't changed
      sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2017.list)"
      sudo apt-get -y -q update
      # Current version breaks TLS
      sudo apt-get install -y -q mssql-server=14.0.3192.2-2
      sudo apt-mark hold mssql-server
      # Choose developer edition
      # https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-environment-variables
      ACCEPT_EULA=y MSSQL_PID=Developer MSSQL_LCID=1033 MSSQL_SA_PASSWORD="MSSQLadmin!" sudo -E /opt/mssql/bin/mssql-conf setup
      # echo "Starting MS SQL Server"
      sudo systemctl restart mssql-server.service

      # Since this is for development and test databases, we don't want the log files
      # to grow forever. Setting the model database sets all databases subsequently
      # created on this server.
      # sqlcmd comes from the client tools, so they have to be installed first.
      # echo "Configuring Logs on MS SQL Server"
      /opt/mssql-tools/bin/sqlcmd -U sa -P MSSQLadmin! <<-CONFIG_DB
      alter database model set recovery simple;
      go
CONFIG_DB
    fi

    # Tiny TDS
    # https://github.com/rails-sqlserver/tiny_tds#install
    # echo "Installing Tiny TDS"
    sudo apt-get install -y -q build-essential
    sudo apt-get install -y -q libc6-dev

    # echo "Installing Free TDS"
    wget https://www.freetds.org/files/stable/freetds-1.1.6.tar.gz
    tar -xzf freetds-1.1.6.tar.gz
    cd freetds-1.1.6
    ./configure --prefix=/usr/local --with-tdsver=7.3
    make
    sudo make install
    cd -
    # echo "Done Installing Free TDS"

    # Without this one gets libsybdb.so.5: cannot open shared object file: No such file or directory - /var/www/dashboard/html/shared/bundle/ruby/2.3.0/gems/tiny_tds-2.1.1/lib/tiny_tds/tiny_tds.so (LoadError)
    # echo "ldconfig"
    sudo ldconfig /usr/local/lib
    # echo "done ldconfig"
    ;;
  *) echo "Unknown database $(database)."
    ;;
esac

# ./build-jekyll.sh
sudo gem install jekyll -v $jekyll_version --no-document

# ./build-prerequisites.sh
# Nokogiri build dependencies (from http://www.nokogiri.org/tutorials/installing_nokogiri.html#ubuntu___debian)
sudo apt-get install -y -q patch zlib1g-dev liblzma-dev


case $os_version in
  18.04)
    # Node
    curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
    sudo bash nodesource_setup.sh
    sudo apt -y -q install nodejs

    # Redis
    sudo apt install -y -q redis-server
    sudo sed -i.original \
      -e '/^supervised no/s/no/systemd/' \
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

    # Sprockets 4 needs Ruby 2.5
    sudo gem install sprockets -v '~> 3.0'
    ;;
  20.04)
    # Node
    sudo apt install -y -q nodejs

    # Redis
    sudo apt install -y -q redis-server
    sudo sed -i.original \
      -e '/^supervised no/s/no/systemd/' \
      /etc/redis/redis.conf
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

if [[ $nginx = 1 ]]; then
  # Nginx
  sudo apt-get install -y -q nginx

  # Certbot
  # Set up for TLS (SSL) by installing certbot
  # https://certbot.eff.org/#ubuntuxenial-nginx
  # Uses Let's Encrypt certificates
  # https://letsencrypt.org/
  sudo add-apt-repository ppa:certbot/certbot -y
  sudo apt-get update -y -qq
  sudo apt-get install certbot -y -qq
  # End set-up for TLS
fi

# Chrome
# A bit of a misnomer to say it's for a non-client deploy. Need to name
# some of the parameters better.
if [[ $client = 0 ]]; then
  # Install Chrome because the world is moving to headless Chrome.
  # From: https://askubuntu.com/a/510186/264753
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add
  echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
  sudo apt-get -y -q update
  sudo apt-get -y -q install google-chrome-stable

  # Need the following if you're going to build webkit for Capybara
  sudo apt-get install -y -q libqtwebkit-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x xvfb
fi

# Bundler version must match the version on the target production box.
# Need both versions during the transition to Bundler 2.
sudo gem install bundler -v 1.17.3 --no-document
sudo gem install bundler -v 2.0.1 --no-document
sudo gem install rails -v $rails_version --no-document

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
