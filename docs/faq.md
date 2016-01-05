### How to add ssh key to authorized keys file

In the below command please make sure that you use double arrow
and not single arrow. Using a single arrow will override the whole
file instead of appending the new ssh key.

```
cat <your_key >> ~/.ssh/authorized_keys
```

### How do I see all the environment variables set in the machine

The third command lists all the environment variables

```
$ bundle exec cap -T
cap config:vars:edit                       # Edit remote .rbenv-vars file
cap config:vars:ensure_shared_file_exists  # Ensure .rbenv-vars file exists before linked_directories check
cap config:vars:show                       # Show current .rbenv-vars file
```

### Deployment is failing. How do I file bug report.

```
bundle exec cap staging deploy --trace 2>&1 | tee tmp/deploy.log
```

### How to find how much memory is left on machine

```
free -mt
```

![a](https://cloud.githubusercontent.com/assets/6399/11230754/79e8cfda-8d6f-11e5-8eee-a074be53bddc.png)


### How to tail log file

```
tail -f log/delayed_job.log

tail log/delayed_job.log -n 200 # will show last 200 lines of the file
```


### How to tail multiple files at the same time

On some machines tail support tails multiple files.

```
tail -f log/delayed_job.log log/unicorn.stdout.log
```

If tail does not support tailing multiple files then install MultiTail. https://en.wikipedia.org/wiki/MultiTail

### How do I execute rails console

ssh into production machine as deployer.

cd into /data/apps/wheel/current.

Now exectute command ./bin/rails console production

### How to run rake task

```
cd /home/deployer/wheel/current
RAILS_ENV=production ./bin/rake db:migrate
```

### How do I find top 10 processes that is taking most memory

```
ps aux --sort=-%mem | awk 'NR<=10{print $0}'
```
