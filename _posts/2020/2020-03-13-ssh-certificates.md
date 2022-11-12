---
title: SSH Certificates
type: post
tags: [ ssh, security ]
comment: true
date: 2020-03-13 08:12:49 +0100
mathjax: true
published: true
---

**TL;DR**

> I've become curious about using CA-signed certificates with SSH

Some days ago I read about using certificates to access a remote SSH server,
using [OpenSSH][]. This set me in curious mode, and I have to admit that I'm
still a bit curious. Here's something, anyway.

# What is this about?

The bottom line of using SSH keys is:

- you generate a *pair of keys*, i.e. a *private* (or *secure*) key and a
  *public* one, bound together;
- you copy the *public* one in a special place in the target server;
- you then instruct the SSH client to use the *private* key when accessing
  the server.

When you do the access, the server makes sure that you really hold the
*private* part of the *public* key it has, and if it's convinced you are in.

Using certificates is a bit more convoluted:

- you still generate the same *pair of keys* as before;
- you send your public key to a Certification Authority (CA), which has its
  own *pair of keys*
- the CA *signs* your public key with its own *private* key, and gives you
  back:
  - a *certificate*, holding your *public* key and the *signature*
  - its own *public* key (it's public, after all)
- you place the *certificate* in a special place in your local system, with
  a specific name;
- you copy the *CA public* key in a special place in the target server;
- you then instruct the SSH client to use the *private* key just like
  before.

There are two important aspects here:

- the certificate file MUST be placed in the same directory as the *private*
  key, and it MUST have a name tied to the *private* key. As an example, if
  the *private* key is placed at `~/.ssh/my-private-key`, then the
  certificate you get back from the CA MUST be placed at
  `~/.ssh/my-private-key-cert.pub`. So the key is to add `-cert.pub` to the
  path of the *private* key.
- you don't need to distribute the *public* key around, you only need to
  configure the CA *public* key properly in the target host. While this
  might seem a complication when used for yourself only, it is pretty useful
  when you have to deal with *a lot* of users access *a lot* of hosts.

# Is it really useful?

There are two ways in which this is useful.

First, supposed that you have $N$ users and $M$ hosts where these users need
to authenticate. Using the regular key-based access, you would have to
configure each user's *public* key in each host, i.e. you should do $N \cdot
M$ configurations (in particular, transferring public keys).

In the CA-based scenario, if you run the CA you have to:

- configure the CA *public* key in every host - $M$ configurations
- for each user, generate a certificate - $N$ operations

i.e. $N + M$ operations. Yay!

The second way in which this mechanism is useful is if you want to provide
time-boxed access to an account on a server. The funny thing about
certificates is that you have to set a *validity period*, so you can provide
a certificate that is only valid over a specific time window and forget
about disabling that access afterwards - the system will do this for you.

# So... how do I do this?

This is really just the gist of it, every real security consideration aside.
If you want to do this *in production*, consult an expert that will tell you
how to protect your CA *secret* key and all these amenities.

## Generate a CA keypair

First of all, you have to be able to impersonate a CA, so generate a key
pair for it:

```shell
$ ssh-keygen -t rsa -N '' -f ca-key
Your identification has been saved in ca-key.
Your public key has been saved in ca-key.pub.
The key fingerprint is:
SHA256:SdlwFliwyIdayODc4WggexPsyV/3V044maomNIzTtlY root@a7f509c6b0a6
The key's randomart image is:
+---[RSA 2048]----+
|o.o .   o+=.     |
|.=.B + o.B       |
|.oB.= = = .  +   |
| o+. o.o..  = o  |
|   ..= .S. . =   |
|    + * E o . .  |
|     + + . .     |
|      + o        |
|     . o         |
+----[SHA256]-----+
```

This will leave you with files `ca-key` (*private*) and `ca-key.pub`
(*public*) in the current directory. You might need to set the permissions
of the directory to something like `rwx------` (i.e. only accessible by the
user) to make things work down the road.

## Distribute the CA public key

Now let's configure the CA *public* key in the target host (assuming that
you can *already* access that host, of course!):

```shell
$ { printf '%s' 'cert-authority ' ; cat ca-key.pub ; } \
   | ssh remote-user@remote-host /bin/sh -c 'cat - >>~/.ssh/authorized_keys'
```

## Generate a user keypair

Now we can generate a user key, much like the CA:

```shell
$ ssh-keygen -t rsa -N '' -f user-key
Your identification has been saved in user-key.
Your public key has been saved in user-key.pub.
The key fingerprint is:
SHA256:0UZosOKdE3cqARLxsjCmGoDcT0a5oMLeD8NbFpv7J38 root@a7f509c6b0a6
The key's randomart image is:
+---[RSA 2048]----+
|  +o..o. ..      |
|o .+.o .oo       |
|*oo.+o=.o +      |
|== ++= = =       |
|= + ..O S        |
|.o = = o         |
|.   B .          |
|   . o . . E     |
|      ..+..      |
+----[SHA256]-----+
```

Now, we have files `user-key` (*private*) and `user-key.pub` (*public*) in
the current directory.

## Sign user's public key

To sign the user's *public* key with the CA's *private* key we would need to
transfer the user's *public* key where the CA is... but in this example it's
all in the same directory 😊

We can proceed with the signature, setting a *Validity* time (option `-V`)
of one day:

```shell
$ ssh-keygen -s ca-key -I user -V +1d user-key.pub 
Signed user key user-key-cert.pub: id "user" serial 0 valid from 2020-03-12T22:13:00 to 2020-03-13T22:14:37
```

Option `-s` tells `ssh` which *private* key to use for signing, and option
`-I` is needed to identify the key in the logs.

This leaves you with file `user-key-cert.pub`, which corresponds to the
*private* key file `user-key`.

## Try it!

We are done! Now we can use our *private* key `user-key` as usual, but `ssh`
will use also the certificate `user-key-cert.pub` to perform the
authentication, because we just configured the CA *public* key, not the
user's *public key*. Moreover, the certificate is valid until tomorrow... so
hurry up!

```shell
$ ssh -i user-key remote-user@remote-host
```

# Summing up

There's still a lot to learn - I mean, I barely scratched the surface. As an
example, I still have to understand what exactly a *principal* is and how to
use it, I tried to configure something but with little luck!

I still think it was very good to learn about this, for two reasons at
least:

- I realized that in this specific case file names *matter*. You cannot just
  name your certificate how you like, you MUST name it after the
  corresponding *private* key. I'm not sure I like it...
- I understood how to give temporary access to a server... although still in
  some *trusty* way.

Cheers!

[OpenSSH]: https://www.openssh.com/
