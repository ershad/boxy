### Local development using Vagrant

You can use Vagrant to test and deploy apps.

* `vagrant up`
* Change `config/setttings.yml` to:
  - `hostname: localhost`
  - `user: vagrant`
  - `ssh_port: 2222`
  - `ssh_identity_file: /Users/sahilm/src/bigbinary/boxy/.vagrant/machines/default/virtualbox/private_key`. The
    full path to the Vagrant private key in `.vagrant/machines/default/virtualbox/private_key`. The above is an
    example full path.
* The deployed app will be available at 'http://localhost:8080'
