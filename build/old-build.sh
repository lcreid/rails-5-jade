#!/bin/bash
sleep 30
set -e


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

# Bundler version must match the version on the target production box.
sudo gem install bundler -v 1.17.3 --no-document
sudo gem install rails -v 6.0.0 --no-document
