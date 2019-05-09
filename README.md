# rails-5-jade
A Vagrant base box with Rails 5.2 with Jekyll and Node on Ubuntu 18.04.

This base box currently includes:

* Ubuntu 18.04.2
* Rails 5.2.2
* Jekyll, because it's what you need for Github Pages
* Postgres, because that's our standard database (and Heroku's standard Rails database)
* Redis (Version TBD)
* Chrome, because it now has a headless option
* PhantomJS, because we used to use Capybara with Poltergeist for integration/acceptance testing. PhantomJS has been abandoned now that headless Chrome has arrived, so PhantomJS and Poltergeist will eventually be removed
* Graphviz, so we can use Rails ERD to generate documentation
* Node 8, for Node development, and for the Rails asset pipeline
* `rbenv`, although you don't have to use either `rvm` or `rbenv`
when using this box

Note that this base box just installs the components in the operating system.
You're free to use as many or as few as you want.
Also, you still have to configure your `Gemfile`
or other configuration files
to use the components.
For example,
you have to configure `config/database.yml` to use Postgres,
if you want to use Postgres.

# Getting Started

This is a standard Vagrant box. First you need to initialize the directory where you want the Vagrant box to reside:

```bash
vagrant init jadesystems/rails-5
```

Then you can start the virtual machine and ssh into it:

```bash
vagrant up && vagrant ssh
```

A useful trick for many use cases of this box is to forward the requests for ssh credentials to your host machine (laptop or desktop), so you only have to maintain keys on the host:

```bash
vagrant ssh -- -A
```

Unless otherwise specified, all the following documentation assumes you're `ssh`d into the vagrant box.

# Create a New Rails App with this Base Box
```
mkdir new-project
cd new-project
vagrant init jadesystems/rails-5-2
vagrant up
vagrant ssh
cd /vagrant
rails new . --database=postgresql --skip-coffee
echo ".vagrant" >>.gitignore
```
Note the last line,
which will avoid putting a bunch of Vagrant's control information
into your repository.
It's unnecessary to put Vagrant's control information into the repository,
and may cause others to have problems when starting the Vagrant machine on their workstation.

(`--skip-coffee` is our standard. You're free to create a new Rails app with whatever options you want.)

You also have to comment out one line
and put another near the end of `config/environments/development.rb`
for each Rails project you create in the Vagrant machine:

```ruby
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

```bash
cd /vagrant
rails server --bind 0.0.0.0
```

You can append `&` to the line to run in the background.
The output from the `rails server` will appear mixed in
with anything else you do in that terminal.

# Using Postgres with Rails
To use Postgres, you have to add the Postgres gem to your `Gemfile`. Add these lines to your `Gemfile`:

```ruby
# Use postgres as the database for Active Record
gem 'pg'
```

If you've created you Rails application in the `/vagrant` directory of the Vagrant box, the database configuration should work as is. If you create the Rails application in any other directory, you have to change the `config/database.yml` file to use username and password `vagrant` for the development and test databases.

Then run:

```bash
rails db:create:all
rails db:migrate
rails db:migrate RAILS_ENV=test
```

The default database user name and password are the same as the directory name where the Rails app resides, typically `vagrant` and `vagrant`.
Obviously you would only use such obvious user names and passwords
for a local development or test database.
Use a better password for production systems, or any system accessible from a network.

You can, of course, change the database owner or password. You have to:

* Create a role in Postgres with database superuser privileges, using the "create role" command
    ```bash
    sudo -u postgres psql -c "create role pg with superuser createdb login password 'pg';"
    ```

* Change the user name and password in all the appropriate places in `config/database.yml`

Note also that you'll have to set up the production database
to be appropriate for your production platform.
The above is merely a template.

To log in to the development database using `psql`:

```bash
psql -U vagrant -h localhost -d vagrant_development
```

Simply replace `vagrant_development` with `vagrant_test` for the test database.

(Note: Unfortunately,
the database user has to have Postgres superuser privileges,
because Rails disables integrity constraints while loading fixtures,
and only the Postgres superuser can disable integrity constraints.)

(Earlier versions of this box used the user name and password `pg`. This box comes with the `pg` role also configured, to maintain backwards compatibility with applications that have a `database.yml` the uses `pg`.)

# Create a New Jekyll Site with this Base Box

```bash
mkdir new-project
cd new-project
vagrant init jadesystems/rails-5-2
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

```bash
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

```bash
sudo systemctl enable redis
```

To start Redis without a reboot, type:

```bash
sudo systemctl start redis
```

# Upgrading a Box
If you want to upgrade the machine on your workstation note that upgrading the box destroys any changes you've made to the machine, e.g. additional packages installed, Redis enabled to start automatically, and Postgres databases. However, upgrading _doesn't_ touch anything in the machine's `/vagrant` directory (the directory shared with your workstation). In particular, SQLite databases will be preserved. Your Rails, Jekyll, and other projects are not touched.

## Get the Updated Box
First, check to see whether there's a new version of the box available:

```bash
vagrant box outdated
```

If there is,
you must first download the updated version.
This doesn't affect any of your running boxes
(it's just updating a local hidden cache of boxes),
so it's safe to do at any time:

```bash
vagrant box update
```

## Update Your Local Machines
Once you've updated the local cache,
you can update a specific machine.
This does affect the machine,
obviously.
You have to stop it, destroy it, and then start it again.
In the directory from which you run the Vagrant machine:

```bash
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

```bash
You need to install GraphViz (http://graphviz.org/) to use this Gem.
```

This is nothing to worry about.
The message is printed whether or not the package is installed.
GraphViz is installed on this box.

## Postgres After Update
The Postgres database is on the base box file system only,
so you have to recreate the Postgres database
after upgrading the box.

Run:

```bash
cd /vagrant
rails db:setup
```

# Running Legacy Rails Applications
Here are some notes if you want to run older Rails applications in this box.

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

Note that there isn't enough disk space on this box to have many versions of Ruby.

### Manually Install Bundler
It appears to be very important that you install Bundler manually
before you install your application's gems:

```bash
gem install bundler
```

Reminder: As with any new development instance,
you need to run Bundler before testing or running the application:

```bash
bundle install
```

### Install the Right Ruby Version
If you haven't used `rbenv` with your Rails application,
you need to figure out which version of Ruby your application runs on.
Once you've done that, run the following
in the top-level directory of your Rails application:

```bash
rbenv local x.y.z
```

where *`x.y.z`* is the Ruby version you want to use.

If your Rails application already has a `.ruby-version` file,
or you just created one as described above,
run:

```bash
rbenv install
gem install bundler
rbenv rehash
```

## MySQL
If your legacy application uses MySQL,
you have to install the MySQL development library
before you install or bundle the gems:

```bash
sudo apt-get install libmysqlclient-dev
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

```bash
sudo VBoxService --timesync-set-start
```

First, get the name of the Vagrant box by entering this on the host:

```bash
VBoxManage list vms
```

Then enter this on the host:

```bash
VBoxManage guestproperty set guest_machine_name --timesync-set-on-restore 1
```

## pg User, Fixtures, and Foreign Key Constraints
Earlier versions of this box didn't create the `pg` user correctly.
You shouldn't run into this problem with boxes after v0.5.0.

When you upgrade the box, you lose the Postgres database.
If the `pg` user isn't created with the right privileges,
then you will get a lot of error messages like:

```bash
ActiveRecord::InvalidForeignKey: PG::ForeignKeyViolation: ERROR:  insert or update on table "cf0925s" violates foreign key constraint "fk_rails_707cb1bbd1"
```

The solution is to first drop the databases, then drop the `pg` user,
Then, recreate the user and database:

```bash
cd /vagrant
rails db:drop
sudo -u postgres psql -c "drop role pg;"
sudo -u postgres psql -c "create role pg with superuser createdb login password 'pg';"
rails db:setup
```

## Old Versions of these Boxes
Versions of this box before v0.3.0
have a lot of rough edges,
including Vagrantfiles that aren't really correct.
If you're having problems,
and you haven't modified your local Vagrantfile
or the machine itself,
it would be worthwhile to try getting a new Vagrantfile
and an up-to-date version of the box:

```bash
vagrant halt
vagrant destroy
rm Vagrantfile # if you haven't modified the Vagrantfile
vagrant init jadesystems/rails-5-2
vagrant up
vagrant ssh
cd /vagrant
bundle install
```

If you have modified your Vagrantfile,
instead of deleting it,
edit it to change the line that starts with `config.vm.box`
to read:

```ruby
config.vm.box = 'jadesystems/rails-5-2'
```

Also,
the [Vagrant documentation](https://www.vagrantup.com/docs/)
will be very helpful if you're trying to figure out a problem.

## Legacy Rails Applications
I got messages like this when I ran `rake test`:

```bash
Could not find rake-10.1.1 in any of the sources
Run `bundle install` to install missing gems.
```

This happened when I didn't install `gem install bundler`
before doing the `bundle install`.
I found the simplest solution is to destroy the box and start over,
carefully following the instructions [here](#Install-the-Right-Ruby-Version).
