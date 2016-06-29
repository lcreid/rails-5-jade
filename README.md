# rails-5-jade
A Vagrant base box with Rails 5 with Jekyll and Node on Ubuntu 16.04.

# Create a New Rails App with this Base Box
```
mkdir new-project
cd new-project
curl -O -L https://github.com/lcreid/rails-5-jade/raw/master/Vagrantfile
vagrant up
vagrant ssh
cd /vagrant
rails new .
echo ".vagrant" >>.gitignore
```
Note the last line,
which will avoid putting a bunch of Vagrant's control information
into your repository.
It's unnecessary,
and may cause others to have problems when starting their Vagrant machine.

You also have to comment out one line
and put another near the end of `config/environments/development.rb`
for each Rails project you create in the Vagrant machine:
```
# config.file_watcher = ActiveSupport::EventedFileUpdateChecker
config.file_watcher = ActiveSupport::FileUpdateChecker
```
If you don't make that change,
and restart the server if you've already started it,
then the Rails server won't see any changes
you make
to your files.

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
curl -O -L https://github.com/lcreid/rails-5-jade/raw/master/Vagrantfile
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
