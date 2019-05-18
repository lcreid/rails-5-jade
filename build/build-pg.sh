#!/bin/bash

# Install Postgres
# This script is useful for local development boxes where a rather obvious username
# and password are not a problem.
# Do not use this for database servers that will be exposed to a network.

sudo apt-get install -y -q postgresql postgresql-server-dev-all
# Leave the `pg` and `vagrant` roles for backwards compatibility.
sudo -u postgres psql -c "create role pg with superuser createdb login password 'pg';"
sudo -u postgres psql -c "create role vagrant with superuser createdb login password 'vagrant';"
sudo -u postgres psql -c "create role ubuntu with superuser createdb login password 'ubuntu';"
