---
title: Bare-bones Web Server
type: post
tags: [ security, web, server, perl, Mojolicious ]
comment: true
date: 2020-01-31 15:53:52 +0100
published: true
---

**TL;DR**

> Need a bare-bones web server to do some testing? Look no further than
> [Mojolicious][]!

In the previous post [Bare Bones Root CA][] we looked into generating a
certificate just a bit further the self-signed one: create a Certification
Authority and have it generate the certificate from a certificate request.

How to test these certificates quickly? [Mojolicious][] can help us quite
quickly. First, let's install it and ensure that we have also support for
SSL, using this `cpanfile`:

```perl
requires 'Mojolicious';
requires 'IO::Socket::SSL';
```

Take a look to [Installing Perl Modules][] if you don't know what to do with
the `cpanfile` above. My preferred way to do that is with [Carton][]:

```shell
carton
```

which creates a sub-directory `local` with modules in `local/lib/perl5`.

At this point, the following program `sample-server.pl` will do:

```perl
#!/usr/bin/env perl
use Mojolicious::Lite;
get '/' => sub { $_[0]->render(text => "Hello, World!\n") };
app->start;
```

[Local version here][].

I know, I know... no `strict`, no `warnings`!!! Well, it's so short and
so... *void of code* that it's really not needed.

To start it, there are a few options. The most straightforward is the
following:

```shell
perl -I local/lib/perl5 sample-server.pl daemon \
   -l 'https://*:3000?cert=./server.crt&key=./server.key'
```

At this point we're ready to start experimenting... or are we? Let's see:

```shell
$ curl https://localhost:3000/
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl performs SSL certificate verification by default, using a "bundle"
 of Certificate Authority (CA) public keys (CA certs). If the default
 bundle file isn't adequate, you can specify an alternate file
 using the --cacert option.
If this HTTPS server uses a certificate signed by a CA represented in
 the bundle, the certificate verification probably failed due to a
 problem with the certificate (it might be expired, or the name might
 not match the domain name in the URL).
If you'd like to turn off curl's verification of the certificate, use
 the -k (or --insecure) option.
```

Well... of course we have to instruct the *client* to trust the *root CA
certificate*, but we're not there yet:

```shell
$ curl --cacert ca.crt https://localhost:3000/
curl: (51) SSL: certificate subject name 'server.example.com' does not match target host name 'localhost'
```

Our example certificate here is for `server.example.com`, but we're sending
our query to `localhost` (i.e. a different name). We can do two things:

- re-generate the certificate for the server, putting `localhost` instead of
  `server.example.com`, OR
- fiddle with `/etc/hosts` to add an entry for `server.example.com`, like
  this:

```shell
$ cat /etc/hosts
127.0.0.1	localhost server.example.com
# ...
```

Now we're finally ready:

```shell
curl --cacert ca.crt https://server.example.com:3000/
Hello, World!
```

Brilliant!

[Mojo]: https://metacpan.org/pod/Mojo
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[Bare Bones Root CA]: {{ '/2020/01/30/bare-bones-root-ca' | prepend: site.baseurl | prepend: site.url }}
[Installing Perl Modules]: {{ '/2020/01/04/installing-perl-modules' | prepend: site.baseurl | prepend: site.url }}
[Carton]: https://metacpan.org/pod/Carton
[Local version here]: {{ '/assets/code/sample-server.pl' | prepend: site.baseurl | prepend: site.url }}
