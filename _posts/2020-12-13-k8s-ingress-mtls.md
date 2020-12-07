---
title: mTLS authentication for (nginx) Kubernetes Ingress
type: post
tags: [ kubernetes, security, OpenSSL ]
comment: true
date: 2020-12-13 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> You can set [Mutual TLS][] authentication with [ingress-nginx][] in
> [Kubernetes][].

We're back with [Kubernetes][] [Ingress][]. Are you happy of it? Tired of
it? I guess this is your time for bailing out!

If you're still there, a little recap. In [TLS for Kubernetes Ingress][] we
looked at how to secure the communication between external clients and the
[Ingress][] resource that acts as a gateway to the internal (HTTP) service.
Then in [Basic Authentication for (nginx) Kubernetes Ingress][] we looked at
how to restrict access to the service by means of *client authentication*.

Now our next step is be aware that [Basic Authentication][] might be
considered a little too... *basic*. Cool people today use [OAuth 2.0][] or,
at the very least, *Mutual TLS Authentication* (also known as *mTLS*). This
is a fancy way of saying that the client connecting to the server MUST
present a valid certificate too.

This is explained in [Client Certificate Authentication][], from the
official documentation for [ingress-nginx][]. Well... a midway between
*hinted* and *explained*, so let's elaborate a bit.

# The plan

First of all, the starting point *MUST* be [TLS for Kubernetes Ingress][].
We can't simply enable TLS authentication for clients without supporting TLS
on the server side.

The plan is the following:

- get certificates for all Certification Authorities involved;
- set them in a [Kubernetes][] [Secret][];
- instruct [ingress-nginx][] to turn client TLS authentication and use them
  for validating clients' certificates.

Sounds familiar?

# Client and CA certificates

As said, your client will need a certificate. Which will need to be signed
by a Certification Authority (CA). Which might be an *intermediate* CA, with
a certificate signed by another CA, in a chain that goes up to a *root* CA.

Nothing new here, it's much like what happens for server certificates. With
a caveat, though: make sure the certificate will be recognized as a *client*
certificate. Take a look to [RFC 5280][], remain more puzzled than how you
started in the first place, then take a look at [Recommended key usage for a
client certificate][] and clear things out. The gist of it is that it's
probably wise to set the `clientAuth` key usage.

You will end up with the following files:

- a *client (secret) key*, which will need to be set in the client only. No
  use for it in this post, yay!
- a *client (public) certificate*, which will need to be set in the client
  only, so that it will provide it as evidence of its identity when
  necessary. Again, no use for it in this post, double yay!
- a *bunch of CA certificates* with all the CAs involved in signing the
  *client certificate*, directly or indirectly.

The files in the last bullet can be concatenated; for good measure start
from the CA certificate that was used to sign the *client* certificate and
add all additional CA certificates up to the root CA certificate, in an
ordered chain. You will end up with a file that we will call
`ca-certificates.pem`, in a failed attempt at being original.

**IF** you want to experiment a bit, you can use [ekeca][] to generate
everything you need. Triple yay!

# Add CA certificates in a secret

I personally prefer to keep the server certificates in one secret and put
the CA certificates for client certificates validation in another one. Which
means creating a separate secret than the one explained in [TLS for
Kubernetes Ingress][], e.g.:

```shell
kubectl create secret generic -n my-namespace tls-authentication \
   --from-file=ca.crt=ca-certificates.pem
```

You will need to adjust for using the right *namespace* and *name* for the
[Secret][], but you get the idea.

# Set the [Ingress][] up

To enable client authentication via TLS, you have to use two *annotations*
(we already saw them in [Basic Authentication for (nginx) Kubernetes
Ingress][]):

- `nginx.ingress.kubernetes.io/auth-tls-verify-client`: set to the *string*
  `on`. Make sure it's a string, i.e. use single or double quotes, otherwise
  I guess you *might* have some problems (didn't verify myself to be
  honest);
- `nginx.ingress.kubernetes.io/auth-tls-verify-client`: set to a string that
  points to the right secret... *including the namespace*! This is extremely
  important, or it will not work. Dont' rely on the [Secret][] living in the
  same namespace as the [Ingress][] - just put it! Use format
  `<namespace>/<secret-name>`.

Example:

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-with-auth
  namespace: my-namespace
  annotations:
    nginx.ingress.kubernetes.io/auth-tls-verify-client: 'on'
    nginx.ingress.kubernetes.io/auth-tls-secret: my-namespace/tls-authentication
    ...
  ...
spec:
  ...
```

# You're done

After installing the changes to the [Ingress][] resource... you should be
done! Make a test or two, clean up files and stay safe!


[TLS for Kubernetes Ingress]: {{ '/2020/12/07/k8s-ingress-tls' | prepend: site.baseurl }}
[Basic Authentication for (nginx) Kubernetes Ingress]: {{ '/2020/12/09/k8s-ingress-basic-authentication' | prepend: site.baseurl }}
[ingress-nginx]: https://kubernetes.github.io/ingress-nginx
[Kubernetes]: https://kubernetes.io/
[Ingress]: https://kubernetes.io/docs/concepts/services-networking/ingress/
[nginx]: https://www.nginx.com/
[OpenSSL]: https://www.openssl.org/
[Secret]: https://kubernetes.io/docs/concepts/configuration/secret/
[Basic Authentication]: https://tools.ietf.org/html/rfc7617
[OAuth 2.0]: https://oauth.net/2/
[Client Certificate Authentication]: https://kubernetes.github.io/ingress-nginx/examples/auth/client-certs/
[RFC 5280]: https://tools.ietf.org/html/rfc5280
[Recommended key usage for a client certificate]: https://security.stackexchange.com/questions/68491/recommended-key-usage-for-a-client-certificate
[ekeca]: {{ '/2020/02/08/ekeca' | prepend: site.baseurl }}
