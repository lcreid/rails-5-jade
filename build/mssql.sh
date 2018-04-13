# https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu
# Server
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2017.list)"
sudo apt-get -y -q update
# Choose developer edition
sudo apt-get install -y -q mssql-server
# https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-environment-variables
ACCEPT_EULA=y MSSQL_PID=Developer MSSQL_LCID=1033 MSSQL_SA_PASSWORD="MSSQLadmin!" sudo -E /opt/mssql/bin/mssql-conf setup
sudo systemctl restart mssql-server.service

# Client
# Needs the keys obtained for server
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/prod.list)"
sudo apt-get -y -q update
ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y -q --no-install-recommends mssql-tools unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
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
