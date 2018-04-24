# rails-5-jade-mssql
A Vagrant base box with Rails 5.2 and MS SQL Server 2017 with Jekyll and Node on Ubuntu 16.04.

NOTE: The MS SQL Server gems have not yet been released for Rails 5.2 (https://github.com/rails-sqlserver/activerecord-sqlserver-adapter/issues/636). Therefore, you should not use this box to create a new Rails project. You can use it for an existing project that uses Rails 5.1 or earlier (I believe). When the MS SQL Server gems are released for Rails 5.2, you can safely use this box to create new Rails 5.2 projects.

This base box includes:

* Ubuntu 16.04.04
* Rails 5.2.0
* Jekyll, because it's what you need for Github Pages
* Microsoft SQL Server 2017, because some clients want to use the database they know
* `sqsh` because it's what `rails dbconsole` needs when used with MS SQL Server
* Redis (3.2 as the 4 series failed testing on this box)
* Chrome, because it now has a headless option
* PhantomJS, because we used to use Capybara with Poltergeist for integration/acceptance testing. PhantomJS has been abandoned now that headless Chrome has arrived, so PhantomJS and Poltergeist will eventually be removed
* Graphviz, so we can use Rails ERD to generate documentation
* Node 8, for Node development, and for the Rails asset pipeline
* `rbenv`, although you don't have to use either `rvm` or `rbenv`
when using this box

Enter issues at: https://github.com/lcreid/rails-5-jade/issues. See the README at: https://github.com/lcreid/rails-5-jade/tree/mssql.

Note that this base box just installs the components in the operating system.
You're free to use as many or as few as you want.
Also, you still have to configure your `Gemfile`
or other configuration files
to use the components.
For example,
you have to configure `config/database.yml` to use MS SQL Server,
if you want to use MS SQL Server.

# Create a New Rails App with this Base Box
```
mkdir new-project
cd new-project
vagrant init jadesystems/rails-5-2-mssql
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

# Using MS SQL Server with Rails
To use MS SQL Server, you have to add the MS SQL Server gems to your `Gemfile`, and change your `database.yml` file.

Add these lines to your `Gemfile`:
```
# Use MS SQL Server as the database for Active Record
gem 'tiny_tds'
gem 'activerecord-sqlserver-adapter'
```

Change the `config/database.yml` file to look like this:
```
default: &default
  adapter: sqlserver
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: localhost
  username: sa
  password: "MSSQLadmin!"

development:
  <<: *default
  database: development

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: test

production:
  <<: *default
  database: production
  username: <%= ENV['DATABASE_USERNAME'] %>
  password: <%= ENV['DATABASE_PASSWORD'] %>
```
Then run:
```
rails db:setup
```
Or in the old days:
```
rails db:create:all
rails db:migrate
rails db:migrate RAILS_ENV=test
```
The default user name and passwords
set up in this box are `sa` and `MSSQLadmin!`.
Obviously you would only use such obvious user names and passwords
for a local development or test database.
Use a better password for production systems, or any system accessible from a network.

To log in to the development database using `sqlcmd`:
```
sqlcmd -S localhost -U SA -P '<YourPassword>'
use development
```
Simply replace `development` with `test` for the test database.

# Create a New Jekyll Site with this Base Box
```
mkdir new-project
cd new-project
vagrant init jadesystems/rails-5-2-mssql
vagrant up
vagrant ssh
cd /vagrant
jekyll new .
echo ".vagrant" >>.gitignore
```
Note the last line,
which will avoid putting a bunch of Vagrant's control information
into your repository.
It's unnecessary to put Vagrant's control information into the repository,
and may cause others to have problems when starting the Vagrant machine on their workstation.

# Starting the Jekyll Server
On the vagrant box:
```
cd /vagrant
jekyll serve --host 0.0.0.0 --force_polling
```
You can append `&` to the line to run in the background.
The output from the `jekyll serve` will appear mixed in
with anything else you do in that terminal.

# Redis
If you need Redis,
this box has a recent stable version of Redis.
However, it's not set up to start automatically.
To set up Redis to start when the Vagrant box starts,
type:
```
sudo systemctl enable redis
```

To start Redis without a reboot, type:
```
sudo systemctl start redis
```

# Upgrading a Box
If you want to upgrade the machine on your workstation note that upgrading the box destroys any changes you've made to the machine, e.g. additional packages installed, Redis enabled to start automatically, and MS SQL Server databases. However, upgrading _doesn't_ touch anything in the machine's `/vagrant` directory (the directory shared with your workstation). In particular, SQLite databases will be preserved. Your Rails, Jekyll, and other projects are not touched.

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
sudo gem update bundler
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

## MS SQL Server After Update
The MS SQL Server database is on the base box file system only,
so you have to recreate the database after upgrading the box.

Run:
```
cd /vagrant
rails db:setup
```

# Running Legacy Rails Applications
Here are some notes if you want to run older Rails applications
in this box.

## `rbenv` or `rvm`
You should use either `rbenv`,
or `rvm`.
Both are good tools for managing multiple versions of Ruby
on the same computer.

Refer to the [`rbenv` documentation](https://github.com/rbenv/rbenv)
for complete information about how to install, set up, and use `rbenv`.

Refer to the [`rvm` documentation](https://rvm.io/)
for complete information about how to install, set up, and use `rvm`.

We prefer `rbenv`,
so the rest of this documentation describes specific `rbenv` commands
you will need to execute,
once you've installed `rbenv`.

### Manually Install Bundler
It appears to be very important that you install Bundler manually
before you install your application's gems:
```
gem install bundler
```

Reminder: As with any new development instance,
you need to run Bundler before testing or running the application:
```
bundle install
```

### Install the Right Ruby Version
If you haven't used `rbenv` with your Rails application,
you need to figure out which version of Ruby your application runs on.
Once you've done that, run the following
in the top-level directory of your Rails application:
```
rbenv local x.y.z
```
where *`x.y.z`* is the Ruby version you want to use.

If your Rails application already has a `.ruby-version` file,
or you just created one as described above,
run:
```
rbenv install
gem install bundler
rbenv rehash
```

# Troubleshooting
## Time
Time synchronization on the Vagrant box seems to fail sometimes.
This can lead to Rails not recognizing changes to files,
so you'll fix something,
but Rails won't reload the changed file,
and you'll think your change didn't do anything.
This may happen after suspending and resuming the Vagrant box,
for example,
if your host is a laptop and it goes to sleep.

You can set the time to sync by entering this in the Vagrant box:
```
sudo VBoxService --timesync-set-start
```
First, get the name of the Vagrant box by entering this on the host:
```
VBoxManage list vms
```
Then enter this on the host:
```
VBoxManage guestproperty set guest_machine_name --timesync-set-on-restore 1
```

## Legacy Rails Applications
I got messages like this when I ran `rake test`:
```
Could not find rake-10.1.1 in any of the sources
Run `bundle install` to install missing gems.
```

This happened when I didn't install `gem install bundler`
before doing the `bundle install`.
I found the simplest solution is to destroy the box and start over,
carefully following the instructions [here](#Install-the-Right-Ruby-Version).
