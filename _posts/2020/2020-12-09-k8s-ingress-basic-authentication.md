---
title: Basic Authentication for (nginx) Kubernetes Ingress
type: post
tags: [ kubernetes, security ]
comment: true
date: 2020-12-09 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> With TLS turned on, [Basic Authentication][] can restrict access without
> giving up passwords around.

Now that we enabled [TLS for Kubernetes Ingress][], we can enable [Basic
Authentication][] (an unsung hero!) to restrict access to the specific
backend service without worrying that our passwords will be flying around
in cleartext.

What follows is not generic, but applies *only* when your [Ingress][]
controller is [ingress-nginx][]. It's the default one, so it should get you
started... but you have been warned!

# How it works

The gist of the whole thing is to provide data to [Kubernetes][] in the
right place and in the right format, so that the automated process will take
it and fit in the rigt place and the right format for the [nginx][] that
powers [ingress-nginx][].

The high-level steps are the following:

- [Basic Authentication][] is supported by [nginx][] through a file of
  username/password pairs, so we will need to generate it;

- the file will have to be fed to [Kubernetes][] via a [Secret][];

- last, we will tell the [ingress-nginx][] controller to use that [Secret][]
  for authenticating users.

Let's start!

# Generate the accounts file

The structure of the accounts file is according to the format for
[.htpasswd][] files used by the [Apache Web Server][apache]. This boils down
to the following line format:


```text
<USERNAME>:<HASHED PASSWORD>
```

Here, *HASHED PASSWORD* indicates that the password is not stored in
cleartext, but first passed through a *hashing function*, i.e. a function
where it's easy to go from the cleartext to the hashed value, but it's
extremely difficult to go the other way around (i.e. get the cleartext from
the hash value).

This means that we will need to generate this hash according to rules that
will be understood by [nginx][]. This can be done using the [htpasswd][]
program, but it can also be easily addressed if you have [OpenSSL][] around,
like this:

```shell
htpasswd_line() {
   local username="$1"
   local password="$2"
   local hashed_password="$(openssl passwd -apr1 "$password")"
   printf '%s:%s\n' "$username" "$hashed_password"
}

{
   htpasswd_line 'foo' 'bar, but baz' 
   htpasswd_line 'justme' 'n0th1ng f4ncy' 
} > accounts.htpasswd
```

We will get something *similar* to the following:

```text
$ cat accounts.htpasswd
foo:$apr1$3yYsOBAs$qjMUbUcrHb5aKf5Y8/R6V1
justme:$apr1$cev9z6sX$k7PZoMLnRISDm4/SN/kcA.
```

This is what we need, on with the rest!

# Adding the accounts file as a [Kubernetes][] [Secret][]

The command-line tool for interacting with [Kubernetes][] provides us with a
simple way to turn the file `accounts.htpasswd` file from the previous
section into a [Secret][].

There's one catch though: the *key* inside the [Secret][] **MUST** be named
`auth` so that the [ingress-nginx][] controller can get it. Hence, if we
want to use the simple route using command-line `kubectl`, we first have to
make sure that the file name is `auth`:

```shell
ln -s accounts.htpasswd auth
```

Now that we have sorted this out, we can settle to call our secret
`basic-authentication`, figure out in which *namespace* it should live
(we'll use `my-namespace` in the example) and proceed:

```shell
kubectl create secret generic -n my-namespace basic-authentication \
   --from-file=auth
```

Let's double check:

```
$ kubectl get secret -n my-namespace basic-authentication -o yaml
apiVersion: v1
kind: Secret
type: Opaque
data:
  auth: Zm9vOiRhcHIxJDN5WXNPQkFzJHFqTVViVWNySGI1YUtmNVk4L1I2VjEKanVzdG1lOiRhcHIxJGNldjl6NnNYJGs3UFpvTUxuUklTRG00L1NOL2tjQS4K
metadata:
  name: basic-authentication
  namespace: my-namespace
  ...
```

Very good, our `data` section contains a string `auth`, whose contents has
been set to the *right* value:

```
$ kubectl get secret -n monitoring basic-authentication \
   -o 'jsonpath={.data.auth}' | base64 -d
foo:$apr1$3yYsOBAs$qjMUbUcrHb5aKf5Y8/R6V1
justme:$apr1$cev9z6sX$k7PZoMLnRISDm4/SN/kcA.
```

# Setting [ingress-nginx][] to use [Basic Authentication][]

Our last step is to tell the [ingress-nginx][] component to set up [Basic
Authentication][] for the specific [Ingress][] resource. This can be done
using *annotations*, which are some *notes* that are added to the resource's
metadata so that other components can find them.

The documentation at [Basic Authentication][ingress-ba] suggests that we set
three of these annotations:

- `nginx.ingress.kubernetes.io/auth-type`: this is set to the string `basic`
  to ask for... [Basic Authentication][];
- `nginx.ingress.kubernetes.io/auth-secret`: this points to the [Secret][]
  created in the previous section. Note that it must be in the same
  *namespace* as the [Ingress][] resource;
- `nginx.ingress.kubernetes.io/auth-realm`: this is a message that is
  presented when users are asked to authenticate. I usually don't read it
  and just concentrate on the two boxes that the browser show to fill in a
  username and a password, so it's OK to put whatever string you see fit.

Example (adapted from [Basic Authentication][ingress-ba]):

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ingress-with-auth
  namespace: my-namespace
  annotations:
    nginx.ingress.kubernetes.io/auth-type:   basic
    nginx.ingress.kubernetes.io/auth-secret: basic-authentication
    nginx.ingress.kubernetes.io/auth-realm:  'Foo requires your credentials!'
spec:
  ...
```

And we're done!

# Wrap up

I hope the notes above can be of help, they're actually just a bad rip-off
of [Basic Authentication][ingress-ba] from the documentation of
[ingress-nginx][], with the possible addition of my errors.


[TLS for Kubernetes Ingress]: {{ '/2020/12/07/k8s-ingress-tls' | prepend: site.baseurl }}
[Basic Authentication]: https://tools.ietf.org/html/rfc7617
[ingress-nginx]: https://kubernetes.github.io/ingress-nginx
[Kubernetes]: https://kubernetes.io/
[Ingress]: https://kubernetes.io/docs/concepts/services-networking/ingress/
[nginx]: https://www.nginx.com/
[.htpasswd]: https://en.wikipedia.org/wiki/.htpasswd
[apache]: https://httpd.apache.org/
[htpasswd]: https://httpd.apache.org/docs/2.4/programs/htpasswd.html
[OpenSSL]: https://www.openssl.org/
[ingress-ba]: https://kubernetes.github.io/ingress-nginx/examples/auth/basic/
[Secret]: https://kubernetes.io/docs/concepts/configuration/secret/
