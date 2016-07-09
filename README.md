# rails-5-jade
A Vagrant base box with Rails 5 with Jekyll and Node on Ubuntu 16.04.

This base box currently includes:

* Rails 5
* Jekyll, because it's what you need for Github Pages
* Postgres, because that's our standard database (and Heroku's standard Rails database)
* Webkit, so we can use Capybara for testing
* Graphviz, so we can use Rails ERD to generate documentation

Note that this base box just installs the components in the operating system.
You're free to use as many or as few as you want.
Also, you still have to configure your `Gemfile`
or other configuration files
to use the components.
For example,
you have to configure `config/database.yml` to use Postgres,
if you want to use Postgres.

# Create a New Rails App with this Base Box
```
mkdir new-project
cd new-project
vagrant init jadesystems/rails5
vagrant up
vagrant ssh
cd /vagrant
rails new .
echo ".vagrant" >>.gitignore
```
Note the last line,
which will avoid putting a bunch of Vagrant's control information
into your repository.
It's unnecessary to put Vagrant's control information into the repository,
and may cause others to have problems when starting the Vagrant machine on their workstation.

You also have to comment out one line
and put another near the end of `config/environments/development.rb`
for each Rails project you create in the Vagrant machine:
```
# config.file_watcher = ActiveSupport::EventedFileUpdateChecker
config.file_watcher = ActiveSupport::FileUpdateChecker
```
Then restart the server if you've already started it.
The out-of-the-box way that `rails server` sees file changes
doesn't work on the Vagrant shared directory.
This change ensures that the Rails server sees file changes
in the Vagrant shared directory.

# Starting Rails Server
On the vagrant box:
```
cd /vagrant
rails server --bind 0.0.0.0
```
You can append `&` to the line to run in the background.
The output from the `rails server` will appear mixed in
with anything else you do in that terminal.

# Create a New Jekyll Site with this Base Box
```
mkdir new-project
cd new-project
vagrant init jadesystems/rails5
vagrant up
vagrant ssh
cd /vagrant
jekyll new .
echo ".vagrant" >>.gitignore
```
Note the last line,
which will avoid putting a bunch of Vagrant's control information
into your repository.
It's unnecessary,
and may cause others to have problems when starting their Vagrant machine.

# Starting the Jekyll Server
On the vagrant box:
```
cd /vagrant
jekyll serve --host 0.0.0.0 --force_polling
```
You can append `&` to the line to run in the background.
The output from the `jekyll serve` will appear mixed in
with anything else you do in that terminal.

# Upgrading a Box
This box is still relatively new,
and we're adding features all the time.
Also, Rails versions change.
You may want to upgrade the machine on your workstation
from time to time.

Note: Upgrading the box destroys any changes you've made
to the machine,
e.g. installing additional packages.
However, upgrading _doesn't_ touch anything in the machine's `/vagrant` directory
(the directory shared with your workstation).
Your Rails, Jekyll, and other projects aren't touched.

In the directory from which you run the Vagrant machine:
```
vagrant halt
vagrant destroy
rm Vagrantfile
vagrant init jadesystems/rails5
vagrant up
vagrant ssh
cd /vagrant
bundle install
```
Note that you may see a message telling you:
```
You need to install GraphViz (http://graphviz.org/) to use this Gem.
```
This is nothing to worry about.
The message is printed whether or not the package is installed.
GraphViz is installed on this box.
The 
