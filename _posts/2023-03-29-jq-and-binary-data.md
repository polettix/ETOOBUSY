---
title: Binary data in jq
type: post
tags: [ jq ]
comment: true
date: 2023-03-29 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> It seems that [jq][] does not help with binary data.

I recently discovered that [jq][] is not prepared to deal with binary data
inside strings.

Let's first create a JSON file with some binary data inside. This respects
the rules set for valid JSON encoding:

```
["\u00e8"]
```

Let's see how it goes when decoded with [JSON::PP][]:

```
$ printf '["\u00e8"]' | perl -MJSON::PP -e 'print decode_json(<>)->[0]' | xxd
00000000: e8
```

If you're wondering, this corresponds to "è" when encoded with ISO-8859-1.

Let's see how this goes with [jq][]:

```
$ printf '["\u00e8"]' | jq -r '.[0]' | xxd
00000000: c3a8 0a                                  ...
```

Ouch. Not only there's an added newline, but the binary data has been
modified. How? Let's see...

```
$ printf '["\u00e8"]' | jq -r '.[0]'
è
```

Now it's clear: the string is being *encoded* in UTF-8 (and added a newline)
before being printed in the output. Guess what? The UTF-8 encoding for
Unicode code point U+00E8 (which is, according to the [relevant current
standard doc][ue8], `LATIN SMALL LETTER E WITH GRAVE`, i.e. `è`), is... what
printed out by [jq][]:

```
$ perl -MEncode=encode -E 'print encode("UTF-8", "\x{e8}\x{0a}")' | xxd
00000000: c3a8 0a                                  ...
```

Admittedly, docs say that the *raw* in option `-r`/`--raw` means "raw
strings" (as opposed to JSON texts), but I'd like it really... *raw*.

Cheers!

[jq]: https://stedolan.github.io/jq/
[Perl]: https://www.perl.org/
[JSON::PP]: https://metacpan.org/pod/JSON::PP
[ue8]: https://www.unicode.org/charts/PDF/U0080.pdf
