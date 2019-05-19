#!/bin/bash

set -e

sudo apt-get update -y -qq
sudo apt-get install -y -q linux-headers-generic
sudo apt-get install -y -q build-essential dkms autogen autoconf libtool
sudo apt-get install -y -q ruby sqlite3 libsqlite3-dev ruby-dev
