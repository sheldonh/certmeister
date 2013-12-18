# Certmeister

Certmeister is a conditionally autosigning Certificate Authority. It was developed for use
with the Puppet infrastructure at Hetzner PTY Ltd.

The service will autosign a certificate request when the configurable access policy permits.
The reference access policy in use by Hetzner PTY Ltd is:

* the Common Name (CN) of the certificate is in the host-h.net domain,
* the requesting client IP address has forward confirmed reverse DNS that matches the CN, and
* the client presents an allowed PSK.

This allows us the convenience of Puppet's autosign feature, without the horrendous security implications.
We could do away with the requirement for a PSK, but then our managed hosting servers would have to put
a firewall rule in place that prevents customers from reaching Certmeister.

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

