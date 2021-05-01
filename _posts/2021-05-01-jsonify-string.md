---
title: JSONify a string
type: post
tags: [ perl ]
comment: true
date: 2021-05-01 09:25:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A little one-liner to encode a string for [JSON][].

A few days ago I wanted to fit a [CSS][] string inside a [JSON][]
object, as a string.

Needless to say, it didn't go well: strings in [JSON][] cannot contain
newlines, so they have to be turned into the corresponding *escape
sequence* (`\n` in this specific case).

As it often (well... *almost always*) happens, I reached out for
[Perl][] to help me:

```shell
perl -MJSON::PP -pe '$x.=$_}{$_=encode_json([$x]);s/^\[|\]$//g' style.css
```

I'm really happy that the [JSON::PP][] module is in CORE, because
[JSON][] is pretty much ubiquitous and having the possibility to handle
it quickly is really helpful.

The one-liner might be a bit *cryptical*, so it deserves an explanation.
For example, what's with that `}{` in the middle?!?

It's actually a trick made possible by the `-p` command-line option,
which *wraps* what you write in the following `while` loop (more or
less):

```perl
while (<>) {
    ... what you write in your one-liner here...
    print STDOUT $_;
}
```

So, in our case, the *code* that is parsed is actually the following:

```perl
while (<>) {
    $x.=$_
}
{
    $_=encode_json([$x]);
    s/^\[|\]$//g;
    print STDOUT $_;
}
```

Now it's easier to see what's going on:

- the `while` loop accumulates all input lines into *package* variable
  `$x`;
- after the loop, `$x` is encoded thanks to [JSON::PP][] and the encoded
  string is put in `$_`. The encoding requires to receive either an
  array reference or a hash reference, i.e. it does not work directly
  with a string, so we embed the `$x` inside an anonymous array;
- the embedding in the array added two square brackets around our
  [JSON][] string, so the substitution takes care to remove them;
- eventually, we print out `$_`.

If you're wondering, the `}{` trick has a name: it's called *the
butterfly operator*, not much because it's an operator (it's not), but
because it *seems* an operator and it resembles... a butterfly 😄

Stay safe and happy May 1<sup>st</sup>!

[JSON]: https://www.json.org/json-en.html
[CSS]: https://www.w3.org/TR/CSS/
[Perl]: https://www.perl.org/
[JSON::PP]: https://metacpan.org/pod/JSON::PP
