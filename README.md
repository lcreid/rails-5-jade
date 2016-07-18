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

# Using Postgres with Rails
There are a couple of commands you have to run in the Vagrant machine
before you can use Postgres as your database in Rails.
You also have to change your `database.yml` file.

The commands should be run in the top level directory of the Rails project.
This example assumes you've put the Rails project in `/vagrant`.
```
sudo -u postgres psql -c "create role pg with superuser createdb login password 'pg';"
```
(Unfortunately,
the database user has to have Postgres superuser privileges,
because Rails disables integrity constraints while loading fixtures,
and only the Postgres superuser can disable integrity constraints.)

Change the `config/database.yml` file to look like this:
```
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  host: localhost
  username: pg
  password: pg

development:
  <<: *default
  database: development

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: test

# production:
#   <<: *default
#   database: production
#   username: <%= ENV['DATABASE_USERNAME'] %>
#   password: <%= ENV['DATABASE_PASSWORD'] %>
```
Then run:
```
rails db:create:all
```
You can, of course,
change the owner or the password in the "create database" commands,
but you have to make sure you change it in all the appropriate places
in the commands above,
and in `config/database.yml`.
Note also that you'll have to set up the production database
to be appropriate for your production platform.
The above is merely a template.

To log in to the development database using `psql`:
```
psql -U pg -h localhost -d development
```
Simply replace `development` with `test` for the test database.
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
Your Rails, Jekyll, and other projects are remain.

## Get the Updated Box
First, check to see whether there's a new version of the box available:
```
vagrant box outdated
```
If there is,
you must first download the updated version.
This doesn't affect any of your running boxes
(it's just updating a local hidden cache of boxes),
so it's safe to do at any time:
```
vagrant box update
```
## Update Your Local Machines
Once you've updated the local cache,
you can update a specific machine.
This does affect the machine,
obviously.
You have to stop it, destroy it, and then start it again.
In the directory from which you run the Vagrant machine:
```
vagrant halt
vagrant destroy
vagrant up
vagrant ssh
cd /vagrant
bundle install
```
The final `bundle install` is required
because the gems are stored in your home directory,
which is lost as part of the update.

Note that you may see a message from the `bundle install` telling you:
```
You need to install GraphViz (http://graphviz.org/) to use this Gem.
```
This is nothing to worry about.
The message is printed whether or not the package is installed.
GraphViz is installed on this box.

# Troubleshooting
Versions of this box before v0.3.0
have a lot of rough edges,
including Vagrantfiles that aren't really correct.
If you're having problems,
and you haven't modified your local Vagrantfile
or the machine itself,
it would be worthwhile to try getting a new Vagrantfile
and an up-to-date version of the box:
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
Also,
the [Vagrant documentation](https://www.vagrantup.com/docs/)
will be very helpful if you're trying to figure out a problem.

