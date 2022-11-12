---
title: APR1 password verification
type: post
tags: [ perl, security ]
comment: true
date: 2021-05-29 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A simple function to check *username*/*password* pairs against
> [htpasswd][] files with passwords encrypted with the `apr1` approach
> ([based on MD5][]).

It's common for me to find solutions where [Basic Authentication][] is
used in conjunction with [TLS][]. The authentication data is often based
on a [htpasswd][]-style file, where password are stored encrypted with
an algorithm [based on MD5][].

This works beyond the [Apache WebServer][], as [htpasswd][] files are
accepted by [NGINX][] too, and it's also possible to generate
[htpasswd][]-compliant files using [OpenSSL][]. In short, there's no
need to install anything from the [Apache WebServer][].

Last, it can be noted that the [OpenSSL][] encryption only supports two
alternatives: the one [based on MD5][] and the one based in `crypt`,
which is marked as insecure. This leaves basically only the former in
play, so we will concentrate on it.

It's easy to verify *username*/*password* pairs generated with this
method, which we can also call *the `apr1` way*, by means of the
[Crypt::PasswdMD5][] module:

```perl
use Crypt::PasswdMD5 'apache_md5_crypt';

sub apr1_verifier ($filename) {
   open my $fh, '<', $filename or die "open('$filename'): $!\n";
   my %encrypted_password_for = map {
      chomp;
      split m{:}mxs, $_, 2;
   } <$fh>;
   return sub ($username, $password) {
      my $encrypted = $encrypted_password_for{$username} or return;
      my ($salt) = $encrypted =~ m{\A\$apr1\$(.*?)\$}mxs or return;
      my $re_encrypted = apache_md5_crypt($password, $salt);
      return $encrypted eq $re_encrypted;
   };
}
```

Function `apr1_verifier` above accepts an [htpasswd][] file as input,
and returns a reference to a sub that can be used to verifications by
passing *username*/*password* pairs, like this:

```perl
my $verifier = apr1_verifier('sample.htpasswd');

while (<>) {
   chomp;
   my ($user, $pass) = split m{\s+}mxs, $_, 2;
   say $verifier->($user, $pass) ? "$user OK" : "$user NOT OK";
}
```

Example session:

```shell
# generate example file sample.htpasswd
$ printf '%s:%s\n' foo "$(openssl passwd -apr1 whatevah)"   > sample.htpasswd
$ printf '%s:%s\n' bar "$(openssl passwd -apr1 whatevahr)" >> sample.htpasswd
$ printf '%s:%s\n' baz "$(openssl passwd -apr1 whatevahz)" >> sample.htpasswd

$ cat sample.htpasswd 
foo:$apr1$7BtlakRN$htkftQ00SWs.lxkQLr54N0
bar:$apr1$8nTR2yrK$5ZAeevQ8q7VKg/6wIMmVX1
baz:$apr1$1sGFbpbg$LpMm9PAhByjjJ6DpmaVC3.

$ perl apr1.pl 
foo whatevah
foo OK
foo barz
foo NOT OK
bar whatevahr
bar OK
baz whatevahz
baz OK
baz adsfa
baz NOT OK
baz whatevah
baz NOT OK
baz hwa
baz NOT OK
baz whatevah
baz NOT OK
```

The whole example program:

```perl
#!/usr/bin/env perl
use 5.024;
use warnings;
use experimental qw< postderef signatures >;
no warnings qw< experimental::postderef experimental::signatures >;

use FindBin '$Bin';
use lib "$Bin/local/lib/perl5";

use Crypt::PasswdMD5 'apache_md5_crypt';

sub apr1_verifier ($filename) {
   open my $fh, '<', $filename or die "open('$filename'): $!\n";
   my %encrypted_password_for = map {
      chomp;
      split m{:}mxs, $_, 2;
   } <$fh>;
   return sub ($username, $password) {
      my $encrypted = $encrypted_password_for{$username} or return;
      my ($salt) = $encrypted =~ m{\A\$apr1\$(.*?)\$}mxs or return;
      my $re_encrypted = apache_md5_crypt($password, $salt);
      return $encrypted eq $re_encrypted;
   };
}

my $verifier = apr1_verifier('sample.htpasswd');

while (<>) {
   chomp;
   my ($user, $pass) = split m{\s+}mxs, $_, 2;
   say $verifier->($user, $pass) ? "$user OK" : "$user NOT OK";
}
```

Happy verifications!


[htpasswd]: https://httpd.apache.org/docs/2.4/misc/password_encryptions.html
[Basic Authentication]: https://en.wikipedia.org/wiki/Basic_access_authentication
[based on MD5]: http://svn.apache.org/viewvc/apr/apr/trunk/crypto/apr_md5.c?view=markup
[Apache WebServer]: https://httpd.apache.org/
[OpenSSL]: https://www.openssl.org/
[NGINX]: https://www.nginx.com/
[Crypt::PasswdMD5]: https://metacpan.org/pod/Crypt::PasswdMD5
[TLS]: https://en.wikipedia.org/wiki/Transport_Layer_Security
