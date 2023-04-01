---
title: Encoding is hard
type: post
tags: [ encoding ]
comment: true
date: 2023-04-01 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Dealing with encoding is hard.

In recent post [Binary data in jq][] I rambled a bit about not getting
binary data from [jq][].

A [comment on the post][] made me realize that I was thinking about the
thing in the wrong way. So here's where I try to take some notes for the
benefit of future me.

So, in my personal representation of the world:

- thoughts and ideas are encoded in a sequence of symbols that I'll call
  *strings of characters*
- *strings of characters* are encoded into *sequences of bytes* to be stored
  in computers.

For what makes sense, the symbols underlying strings of characters use
Unicode characters.

When these sequences of characters are represented in a program, it adopts
whatever strategy to deal with them. As an example, as sequences of objects,
each representing a character. (Maybe not, let's just keep it simple). How
the program/language decides to do this representation should not matter to
us.

When these strings of characters have to be saved or transferred, it makes
sense to *encode* them into a sequence of bytes. One way to do this is using
the UTF-8 encoding. At this point, we have a sequence of different objects,
each being a byte.

In this context, we expect the following round-trip to make sense:

```
characters --[encoding]-> bytes --[decoding]-> characters
```

If we get the same characters the two operations make sense.

On the other hand, there might be multiple ways of doing the encoding. It
might be the UTF-8 encoding, or whatever other rule that allows generating a
sequence of bytes that can eventually be turned back into characters.

In some contexts, people have some edge to choose several ways of doing the
encoding. As an example, JSON allows strings to contain UTF-8
representations, or `\uXXXX` representations for some characters, or
`\uXXXX\uYYYY` for other ones.

As an example, let's consider a string containing the G-clef character `𝄞`,
which is Unicode codepoint U+1D11E. The JSON encoding rules allow for the
following sequences of bytes (written as hexadecimal pairs, another
encoding!) to represent a string containing the G-clef character:

```
f0 9d 84 9e
5c 75 44 38 33 34 5c 75 44 44 31 45
```

The first line is a plain UTF-8 encoding. The second one is one alternative
that is available and is, for example, explained also in [RFC 8259][].

As they are both valid representation of the G-clef character in a JSON
string, using either one is good and supports the round-trip above. On the
other hand, we *cannot* start from a bytes-oriented representation, turn it
into a stream of characters, re-encode it in bytes and expect to get the
same thing.

Hence, my whole [jq][] post is somehow valuable only insofar that it advices
to *not* use [jq][] for binary data and, to re-iterate, it's not a fault of
[jq][] but of my expectation that it should support the encoding round-trip
in a way that it was not designed for.

My take-away is: to encode binary data, use base64. This will generate a
sequence of bytes that can also be interpreted as characters suitable for a
string in JSON, etc. etc. and also supports going back to the exact binary
data we started from.

Now I'm even doubting that this might not work, but I'll call this a day.



[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Binary data in jq]: {{ '/2023/03/29/jq-and-binary-data/' | prepend: site.baseurl }}
[jq]: https://stedolan.github.io/jq/
[comment on the post]: https://github.com/polettix/ETOOBUSY/issues/29
[RFC 8259]: https://www.rfc-editor.org/rfc/rfc8259.txt
