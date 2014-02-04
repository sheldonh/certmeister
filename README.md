# Certmeister

Certmeister is a conditionally autosigning Certificate Authority. It was developed for use
with the Puppet infrastructure at Hetzner PTY Ltd.

The service will autosign a certificate request when the configurable access policy permits.
The reference access policy in use by Hetzner PTY Ltd is:

* the Common Name (CN) of the certificate is in the host-h.net domain,
* the service has no record of already having signed a certificate for that CN, and
* the requesting client IP address has forward confirmed reverse DNS that matches the CN.
* Requests to fetch certificates are always allowed.
* Requests to delete certificates are only allowed when they originate from
  a secure operator network.

This allows us the convenience of Puppet's autosign feature, without the horrendous security implications.

This repository currently builds three gems:

* _certmeister_ - the CA, some off-the-shelf policy modules and an in-memory cert store
* _certmeister-redis_ - a redis-backed store
* _certmeister-rack_ - a rack application to provide an HTTP interface to the CA

An example, using redis and rack and enforcing Hetzner PTY Ltd's policy, is available in [contrib/config.ru](contrib/config.ru).

To hit the service:

```
$ curl -L \
    -d "psk=secretkey" \
    -d "csr=$(perl -MURI::Escape -e 'print uri_escape(join("", <STDIN>));' < fixtures/client.csr)" \
    http://localhost:9292/ca/certificate/axl.starjuice.net
```

## Testing

Because we test both certmeister and certmeister-redis with `rake spec`, you need redis up if you want to run the tests. It's easy:

* Install redis-2.8.4 or later.
* Start redis.
* Run tests.
* Stop redis.

```
sudo yum install -y ansible
sudo ansible-playbook -i contrib/hosts contrib/redis.yml
redis-server --logfile /dev/null &
rake spec
kill %1; wait %1
```

## Releasing

If you work at Hetzner and need to release new versions of the gems, do this
(obviously only after making sure the tests run and you have no uncommitted
changes):

```
bundle exec rake bump:patch # or bump:minor or bump:major
bundle
git add .semver Gemfile.lock
git commit -m "Bump to version $(bundle exec semver)"
bundle exec release
```
