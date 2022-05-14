---
title: ActiveDirectory password encoding in Perl and shell
type: post
tags: [ active directory, ldif, perl, shell ]
comment: true
date: 2022-05-16 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I guess the title **is** the **TL;DR**

In previous post [ActiveDirectory password reset with LDIF][] we saw the
basic algorithm to generate a [LDIF][] file for changing passwords in
ActiveDirectory.

The most tricky part is dealing with the encodings in the right way, so
let's look at a couple of examples, one in [Perl][] and one in shell
(with the help of some programs, hoping they're available).

Let's go [Perl][] first:

```perl
use Encode 'encode';
use MIME::Base64 'encode_base64';
my $password = 'newPassword';
print encode_base64(encode('UTF-16LE', qq{"$password"}));
```

We can also go with a one-liner, **BUT** take care that you must know
that your terminal is set to UTF-8 for the following example to work
properly (i.e. to substitute `newPassword` with something different,
e.g. containing accented characters etc.):

```shell
perl -MEncode=encode -MMIME::Base64=encode_base64 -Mutf8 \
    -e 'print encode_base64(encode("UTF-16-LE", qq{"newPassword"}))'
```

So... some plain(er) shell without [Perl][]. Apart from the nightmare of
a system *without* [Perl][] (alas, they exist!), the [UTF-16LE][]
encoding can be handled with [iconv][] and the final encoding with
[base64][]:

```shell
printf %s '"newPassword"' | iconv -f UTF-8 -t UTF-16LE | base64
```

Note that `newPassword` is wrapped in double quotes **and** single
quotes. The single quotes allow preserving the double ones. Not the most
readable thing in the world I guess, but this is life.

Stay safe and encoded!



[Perl]: https://www.perl.org/
[ActiveDirectory password reset with LDIF]: {{ '/2022/05/15/ad-password-reset/' | prepend: site.baseurl }}
[LDIF]: https://www.ietf.org/rfc/rfc2849.txt
[iconv]: https://en.wikipedia.org/wiki/Iconv
[base64]: {{ '/2020/08/13/base64/' | prepend: site.baseurl }}
[UTF-16LE]: https://en.wikipedia.org/wiki/UTF-16#Byte-order_encoding_schemes
