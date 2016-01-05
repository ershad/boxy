### How to add monit for monitoring

* Configure monit in your node file:

```
"monit": {
  "username": "xxxx", // Username to access monit web console
  "password": "xxxxxx", // Password to access monit web console
  "address": "localhost", // Change to your server ip to access to allow web-access
  "notify_email": "alerts@your-company.com", // email to send notification to
  "mailserver": {
    "host": "localhost", // Example "smtp.mandrillapp.com"
    "port": 587,
    "username": "SMTP_USERNAME", // Obtain this by logging into Mandrillapp for account (https://mandrillapp.com)
    "password": "SMTP_PASSWORD" // Obtain this by logging into Mandrillapp for account (https://mandrillapp.com)
  },
  "mail_format": {
    "from": "monit@your-app-name.com"
  }
}
```
* [monit cookbook](https://github.com/apsoto/monit)

* For monitoring processes like nginx, postgresql, memcached along with root partition, update `recipe[boxy-rails::monit]` in node's run list

```json
....
  "run_list": [
    ....
      "recipe[boxy-rails::monit]",
    ....
  ],
....
```
