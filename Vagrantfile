# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = 'jadesystems/rails-5-1'
  # Create a forwarded port mapping which allows access to a specific port
  # This one is for running Rails (puma, mongrel)
  # Note that when you run `rails server`, you need to specify that it
  # bind to host 0.0.0.0, not localhost, or the port forwarding won't work.
  # `rails s -b 0.0.0.0`
  config.vm.network 'forwarded_port', guest: 3000, host: 3000, auto_correct: true
  # This one is for Jekyll
  # Note that when you run `jekyll serve`, you need to specify that it
  # use host 0.0.0.0, not localhost, or the port forwarding won't work.
  # `jekyll serve -H 0.0.0.0 --force_polling`
  config.vm.network 'forwarded_port', guest: 4000, host: 4000, auto_correct: true
  # Customize the amount of memory on the VM. Wee need a GB:
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
end
