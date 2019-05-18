# Client
# Needs the keys obtained for server
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/prod.list)"
sudo apt-get -y -q update
ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y -q --no-install-recommends mssql-tools unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
# `rails dbconsole` uses `sqsh`
sudo apt-get install -y -q sqsh

# Tiny TDS
# https://github.com/rails-sqlserver/tiny_tds#install
apt-get install build-essential
apt-get install libc6-dev

wget http://www.freetds.org/files/stable/freetds-1.00.86.tar.gz
tar -xzf freetds-1.00.86.tar.gz
cd freetds-1.00.86
./configure --prefix=/usr/local --with-tdsver=7.3
make
sudo make install
cd -
# Without this one gets libsybdb.so.5: cannot open shared object file: No such file or directory - /var/www/dashboard/html/shared/bundle/ruby/2.3.0/gems/tiny_tds-2.1.1/lib/tiny_tds/tiny_tds.so (LoadError)
sudo ldconfig /usr/local/lib
