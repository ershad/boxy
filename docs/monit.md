### What is monit

[monit](https://mmonit.com/monit/documentation/monit.html#NAME) is a
tool to monitor services.

Sometimes processes die. Sometimes processes go rogue and start taking
too much memory. If these processes are not killed then they will take
all the available memory and the machine will go down.

monit can help us monitor these services.

### Show me a real exampel of something being monitored

Below is a real example of monit config for monitoring unicorn.

```
check process wheel_unicorn
  with pidfile /data/apps/wheel/shared/tmp/pids/unicorn.pid
  group unicorn
  group unicorn_wheel

  start program = "/bin/su deployer -l && /bin/bash -c 'cd /data/apps/wheel/current; RAILS_ENV=production /data/bin/rbenv-exec bundle exec unicorn_rails -l /data/apps/wheel/shared/tmp/sockets/unicorn.sock -c /data/apps/wheel/current/config/unicorn/production.rb -d -D -E production'" with timeout 30 seconds
  stop program = "/bin/bash -c 'kill -QUIT `cat /data/apps/wheel/shared/tmp/pids/unicorn.pid`'" with timeout 30 seconds

  if failed unixsocket /data/apps/wheel/shared/tmp/sockets/unicorn.sock then restart
  if 2 restarts within 15 cycles then timeout
  if totalmem is greater than 600 MB then restart
```


### How do I check if processes are running ok

```
monit -I summary
```

The output of above command might look like below.

```
Process 'wheel_delayed_job_1'  Running
Process 'wheel_unicorn'        Running
```

You can also do `monit status` to get a detailed status report.

### How do I syntax check that my configuration is ok

```
monit -t
```

Above command just checks that there is no syntax error in the
configuration file anywhere.

### How do I restart, start or stop a process

```
monit restart wheel_unicorn
monit stop wheel_unicorn
monit start wheel_unicorn
```

If you execute any of the above command then you will get your prompt
back and you will see absolutely nothing on the screen. That will leave
you wondering what happened. Did the process restart or not.

monit behaves like it because the monit processes those commands
asynchronously. Yes asynchornous processing happens outside of
JavaScript too.

Then how do I know if the process has really restarted or not. For this
we need to keep an eye on `monit -I summary`.

Howeve we need to keep executing `monit -I summary` in a loop
continouslay to see the status updated every 1 second. Use follwoing
command to do that.

```
watch -n 1 monit -I summary
```

Above command will keep displaying monit summary result by executing
that command every one second.

Output of above command would be something like this.

```
Process 'wheel_delayed_job_1'  Running
Process 'wheel_unicorn'        Running
```

Now if you execute `monit restart all` then the output for a few seconds
will be something like as given below.

```
Process 'wheel_delayed_job_1'  Running - restart pending
Process 'wheel_unicorn'        Running - restart pending
```

It means restart is still pending. And then if restart goes ok then the
status will switch back to `Running`.

### Where are these configuration files stored

`monitrc` files is stored at `etc/monit/monitrc`.

All the processes that needs to be monitored are stored at
`etc/monit/config.d/*`.

### How do I reload monit after making changes to monitrc

```
monit reload
```

### How do I ask monit to quit

```
monit quit
```

### How do I see verbose logging

In order to see verbose logging start monit as shown below.

```
monit quit # first quit monit
monit -v # start monit in simple verbose mode
moint -vv # start monit extra verbose mode
```

