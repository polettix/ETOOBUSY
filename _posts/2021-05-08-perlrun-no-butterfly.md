---
title: 'Avoid the "butterfly operator" with command-line options'
type: post
tags: [ perl, perlrun ]
comment: true
date: 2021-05-08 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> When a [giant][] chimes in, it's impossible to avoid learning
> something.

In recent post [JSONify a string][] I showed a little one-liner to...
*JSONify a string*:

```shell
perl -MJSON::PP -pe '$x.=$_}{$_=encode_json([$x]);s/^\[|\]$//g' style.css
```

It uses the so-called "butterfly operator" (which is not a real
operator, just a visual trick) to collect *all* the input in scalar
`$x`, before using it to generate the encoded string.

Having written about it was indeed *very* fruitful.

[Αριστοτέλης Παγκαλτζής][giant] took a look and had the kindness to
[share a simpler way][tweet] to do this slurping from the command line:

![tweet screenshot]({{ '/assets/images/ap-tweet-0777.png' | prepend: site.baseurl }})

So... I learned that [option `-0xxx`][] allows setting the input
separator `$/` from the command line as an *octal* value, and that using
`0777` is the *conventional* way to say *just get everything*.

Result: no need to use the *butterfly operator* any more, because when
we set the input separator like this, the very first read action will
take everything in one single sweep and we can use `encode_json`
immediately.

In this case, then, the *equivalent* code (thanks to the `-p` option)
becomes something like this:

```perl
while (<>) {
    $_ = substr encode_json([$_]), 1, -1;
    print STDOUT $_;
}
```

Brilliant!


[giant]: http://plasmasturm.org/about/#me
[JSONify a string]: {{ '/2021/05/01/jsonify-string/' | prepend: site.baseurl }}
[tweet]: https://twitter.com/apag/status/1389260909294542851
[option `-0xxx`]: https://perldoc.perl.org/perlrun#-0%5Boctal/hexadecimal%5D
