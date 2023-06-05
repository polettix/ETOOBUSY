---
title: Packet Dissection Amarcord...
type: post
tags: [ perl, networking, dissection, wireshark ]
comment: true
date: 2023-06-05 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Back to packet dissection for troubleshooting...

[Amarcord][] is a movie by Federico Fellini that mean "I remember". Well,
after a *few* years (some 20), I'm back looking at raw network-level
captures from `tcpdump` to figure out what's going on with some devices that
seems to give bad answers.

On the other hand, it might be the client that is not able to understand
those same answers. I'm more inclined to blame the server, though.

At a higher level, I had the joy of coding a quick client myself in
[Perl][], sending the same request to the server and *not getting an error*.
Which led me to think that the *other* client was to blame.

Alas, comparing the two *real* low-level requests, and the answers, got me
back to my original thought: the server is probably to blame. This also
seems to be supported by [Wireshark][]'s internal dissector, which seems to
point out that there's extra stuff in the answer to the first client.

> If you're wondering, the two queries have some slight differences, which
> might actually trigger the wrong behaviour. I didn't find anything around,
> though, which might mean bad web surfing skills, OR a decreased quality in
> queries to search engines.

> NO, I didn't ask ChatGPT.

Now I'm left with doing some manual low-level bitwise dissection of the
packets, to find out where the truth lies. Which is something I was doing
some 20+ years ago, leading to my minimal yet acknowledged contribution to
the venerable [Wireshark][] itself, yay!

Stay safe!

[Perl]: https://www.perl.org/
[Amarcord]: https://it.wikipedia.org/wiki/Amarcord
[Wireshark]:https://www.wireshark.org/ 
