### boxy

This is a collection of [Chef](https://www.chef.io) scripts to build a box to deploy a Ruby on Rails application.
Currently it supports ubuntu and centos.

Boxy uses [chef-solo](http://docs.opscode.com/chef_solo.html) which is a standalone
version for chef client and does not cost money.

### Step 1 - Things you need before getting started.

* You need a name for the application you are going to deploy. We are going to deploy Rails application
  named [`bigwheel`](https://github.com/bigbinary/wheel).
* You need to have read access to the github repository.
* You need IP address of the box. we got IP address 107.170.45.179 at digital ocean.
* You need to have root access to the box.

### Step 2 - Copy your ssh key to the box.

If you are using linux then probably you already have `ssh-copy-id` installed on your machine.

If you are using mac then perform `brew install ssh-copy-id` on your machine.

Now copy your ssh key to the box by executing following command.

```
ssh-copy-id root@ip_address_of_your_box
```

### Step 3 - Clone boxy.

```bash
git clone https://github.com/bigbinary/boxy.git
cd boxy
bundle install
```

### Step 4 - Configure settings.yml.

```
cp config/settings.yml.example config/settings.yml
```

Now open `config/settings.yml` and change

* `bigwheel:` to the application name. There are two occurrences of 'bigwheel'. Make sure to change it to your application name at both the places.
* `xx.xx.xx.xx` in hostname to the ip address of the box.

### Step 5 - Build the node file.

Copy starter configuration to build the machine. If you are using centos
then copy `centos.json`. If you are using `ubuntu` then use
`ubuntu.json`.

```
cp nodes/centos.json nodes/bigwheel.json
cp nodes/ubuntu.json nodes/bigwheel.json
cp nodes/example.json nodes/bigwheel.json
```

### Step 6 - Add your public key to the node file.

Open `nodes/bigwheel.json` and look for `authorized_keys`. It takes an array of public keys.

Here you should put the public keys of all the people who need access to the box.

```
"authorized_keys": ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLP4WlZl+w+PkFfQaCO9poKje5Zvo6YEnhfqpvxtKNFXIzQHM4unro/oTFmmKhW+zIpPLmT4WA5B/n5ETupO804h6dp03pOXnYghHe4sCUI41QdAATT+ln+BxaoQWzzWCKPnBNVx/NUmNQs7QGeoWEhs0OHZydJ66C0T5XWBGlV70WdThAHpCE3auuAs62knJepaBTnkgj6Ws+FrDC2GmHBeEmhkRbxIJfXwfuhmLhT9jykmxoCPEe+HPn4AxKFA9jGhOcnlGTt+XxrY+6eWJ4EWmZe20m+CZL5m1irIaYpSTsGJvdOOmRIt5IXhAakMwt3IY4BbVdtm3o4frJMSGp vipulnsward@gmail.com"]
```

### Step 7 - Change the application name.

Open `nodes/bigwheel.json` and look for `applications` key.
Here you will find a key named `name`.
Change the value from `bigwheel` to your application name.

### Step 8 - Build the box.

Now it's time to actually build the box.
Again I am using bigwheel because that is the name of my application.
You should put the name of your application.

```
bundle exec rake build
```

This will take some time, as the script goes through installing different software packages for
postgresql database, memcached, ruby, etc, and configures them.

All output goes to `log/build.log`. Look at the log file if you
encounter an error.

Next step is to verify that basic things are working in the box.

### Step 9 - Verify that things are looking ok.

```bash
[user@host.local ~]$ ssh deployer@ip_address_of_the_box

[deployer@server.ip ~]$ ls /data
```

If you see output something like the following then everything is ok.

```bash
apps  bin  rbenv  tmp
```

Following command should show the name of your application.

```bash
[deployer@server.ip ~]$ ls /data/apps
```

If you install pg then execute following command.
Before you execute the command make sure that you are logged in as
deployer. If you are logged in as root then following command will not
work.

```bash
psql -h localhost -U postgres
> When prompted enter welcome as password

You should see psql screen where you can enter \l
and that should list three databases postgres, template0 and template1.
```

Exit from the remote server

```bash
[deployer@server.ip ~]$ exit
```

### Step 10 - Capify the application.

Please note that following commands need to be run on the local machine, instead of the server.

Now the Rails application needs to be configured with [capistrano](https://github.com/capistrano/capistrano).

To capify the application execute following command. In the following commands replace `full_path_to_the_rails_application`
with the actual path to your rails application on developer machine.

```bash
bundle exec rake "capify_app[bigwheel]" APP_PATH=full_path_to_the_rails_application
```

### Step 11 - Install added gems in your rails application.

Previous step added a few gems to the `Gemfile` of your rails application.

```
cd into your rails application
bundle install
```

### Step 12 - Modify capistrano deploy configuration file.

```
cd into your rails application
```

Open `config/deploy.rb` and change the name of the application from `bigwheel` to match with your application name.

```
set :application, 'bigwheel'
```

### Step 13 - Set the repository url.

```
cd into your rails application
```

Open `config/deploy.rb` and change  the github url of your application.

```
set :repo_url, 'git@github.com:bigbinary/bigwheel.git'
```

### Step 14 - Set the database template path.

```
cd into your rails application
```

Open `config/deploy.rb` and change the path to database template.

```
set :template_dir, 'config/deploy/templates/database_mysql.yml.erb'
```

### Step 15 - Commit changes and push it to github.

Commit all changes made in previous steps to the deploy branch, and push to GitHub.

```
git add .
git commit -m "Setup Capistrano using boxy"
git push
```

### Step 16 - SSH agent forwarding.

`boxy` and `capistrano` use ssh agent forwarding for deploying applications.
You need to configure your local machine to support this, so that deployment can be done via capistrano.
Detailed guide to achieve this is [available at github help](https://help.github.com/articles/using-ssh-agent-forwarding) .

### Step 17 - Deploy application using capistrano.

Next, setup our application on server and deploy changes to it.

```
bundle exec cap production deploy:setup
```

Now login as deployer and visit `/data/apps/aapc7atlis/shared/.rbenv-vars` and put in all required environment variables.

```
bundle exec cap production deploy
```

### Step 18 - Verify that all services are running.

```
bundle exec cap production "monit:exec[status]"
```

Our Rails App has now been successfully deployed. The end result can be found at http://ip_address_of_box .

### Useful commands

Run following command to get a list of available commands you can try.

```
bundle exec cap -T
```

Here are some useful commands.

```
bundle exec cap production deploy - Update the server with new version from the `production` branch.
bundle exec cap staging deploy - Update the server with new version from the `staging` branch.

bundle exec cap production console - run ssh connection to the remote
bundle exec cap production rails:console - run remote interactive rails console

bundle exec cap production "log:tail" - show the log file of the log/production.log.
bundle exec cap production "log:tail[*]" - show tail of all logs in the log folder: log/*.log
bundle exec cap production "log:tail[delayed_job]" - show tail of log in the log folder log/delayed_job.log

bundle exec cap production "task:exec[task_name]"
bundle exec cap production "task:exec[db:migrate]"

bundle exec cap production db:backup - take a snapshot of current remote database
bundle exec cap production db:restore - restore db with the most recent backed up data
bundle exec cap staging db:dump_download - downloads the latest backed up file from remote server to local machine
```

A more detailed information about advanced tasks can be found at [Boxy-Cap](https://github.com/bigbinary/boxy-cap)
