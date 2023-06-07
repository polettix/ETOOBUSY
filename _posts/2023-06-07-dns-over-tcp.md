---
title: DNS over TCP
type: post
tags: [ dns, networking ]
comment: true
date: 2023-06-07 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [DNS][] over [TCP][] has two added bytes for length.

[DNS][] is a protocol that, whenever possible, tries to go on [UDP][]. This
is usually due to the fact that requests and responses are usually quite
short, so they easily fit one single [UDP][] packet; at that point, going
for [TCP][] only means losing in efficiency.

At least, that was the approach back in the day, when security was much less
of a concern with this new toy that was only meant for an *elite*.

Still, it was already recognized that *sometimes* answers might require to
transfer *moar* data, so [the standard][DNS] discusses the [TCP][]-based
responses 
alternative too. One common approach is often to try [UDP][] first, then
fall back to [TCP][] in case a single [UDP][] packet doesn't cut it. Or,
rather, *it does **cut** it*.

One such occasion is with *zone transfers*, i.e. when an authoritative
server is requested to provide all resource records for a zone at once
(using the `AXFR` command, i.e. *Asynchronous Transer Full Range*). Nowadays
this is usually restricted to a few selected and authorized requestors,
because getting this kind of detailed data can tell an attacker *a lot* and
provide a pretty accurate map for guiding the attack, lowering its cost etc.
etc.

In this case, just a handful of resource records usually mean that the
[UDP][] threshold is overcome and [TCP][] comes to the rescue.

In this case, I found [an interesting and amusing fact][amusing]:

> \[...\] The message is prefixed with a two byte length field which gives
> the message length, excluding the two byte length field.  This length
> field allows the low-level processing to assemble a complete message
> before beginning to parse it.

*Strictly* speaking, this length prefix is not needed: the structure of a
[DNS][] packet (be it a request or a response) is pretty well defined
*internally* and does not need this kind of outer boundary definition.

On the other hand, making the length explicit eases the life of the receiver
end, which can then easily divide the data from the [TCP][] connection in
chunks *before* starting to parse stuff. This allows for simpler
implementations, arguably less memory time (parsing can occur all at once,
not incrementally as new data arrives).

Overall, I think it's a good deal for just two added bytes.

Stay safe!


[Perl]: https://www.perl.org/
[DNS]: https://www.rfc-editor.org/info/std13
[UDP]: https://www.rfc-editor.org/info/std6
[TCP]: https://www.rfc-editor.org/info/std7
[amusing]: https://datatracker.ietf.org/doc/html/rfc1035#autoid-47
