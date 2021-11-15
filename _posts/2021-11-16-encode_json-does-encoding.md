---
title: 'encode_json does encoding'
type: post
tags: [ perl, json ]
comment: true
date: 2021-11-16 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> Unsurprisingly, [`encode_json`][] encodes stuff.

Well, I'm not suddenly become crazy. I mean, I became crazy little by
little, but I'm digressing.

I was curious about whether a [JSON][]-encoded string would still have
to be UTF-8 encoded before being printed (and later decoded after having
been read as an octet stream).

It turns out it's not necessary: the [JSON][]-encoded string is
*already* also UTF-8 encoded, so it's just necessary to print that out
to a `:raw` filehandle.

And of course the contrary applies too: just read the stuff like `:raw`
octets, and let [`decode_json`][] do the rest.

Nifty!

[Perl]: https://www.perl.org/
[`encode_json`]: https://metacpan.org/pod/JSON::PP#encode_json
[`decode_json`]: https://metacpan.org/pod/JSON::PP#decode_json
[JSON]: https://json.org/
