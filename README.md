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

Certmeister is the core of a fancy web service that does this:

```
cat request/client.csr | openssl x509 -req -CA CA/ca.crt -CAkey CA/ca.key -CAcreateserial -addtrust clientAuth > CA/signed/<cn>.crt
```

To hit the service:

```
$ curl -L \
    -d "psk=secretkey" \
    -d "csr=$(perl -MURI::Escape -e 'print uri_escape(join("", <STDIN>));' < request/client.csr)" \
    http://certmeister.hetzner.co.za/certificate/$(hostname --fqdn) > request/client.crt
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
