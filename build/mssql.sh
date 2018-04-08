# https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu
# Server
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2017.list)"
sudo apt-get -y -q update
# Choose developer edition
sudo apt-get install -y -q mssql-server
ACCEPT_EULA=y MSSQL_PID=Developer MSSQL_LCID=1033 MSSQL_SA_PASSWORD="MSSQLadmin!" sudo -E /opt/mssql/bin/mssql-conf setup
sudo systemctl restart mssql-server.service

# Client
# Needs the keys obtained for server
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/prod.list)"
sudo apt-get -y -q update
ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y -q --no-install-recommends mssql-tools unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
