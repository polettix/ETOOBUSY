---
title: 'Removing a session in Mojolicious'
type: post
tags: [ mojolicious, web ]
comment: true
date: 2023-04-22 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Just a note about removing sessions in [Mojolicious][].

When I wrote [No back button after logout][], I forgot to take note of an
interesting fact about removing a session in [Mojolicious][].

The fact is: you don't control it from the server side.

I mean, the server can *ask* the browser to remove the session, by getting
rid of the cookie. On the other hand, if for some reason the browser is not
collaborating (e.g. refusing to delete the session cookie), then the session
will stick up to the expiration time.

This is *hardly* unexpected in a system that stores sessions completely on
the client side. Still, it surprised me the first time I saw this in action,
so it might surprise others (or me in a few months since now).

If you're wondering *how* I was biten by this particular set of teeth, it
suffices to say that [curl][] has *two* options for dealing with a so-called
*cookie jar*:

- option `-c` is the read-write alternative, which complies with what the
  server asks to do, and...
- option `-b` is the read-only alternative, which disregards requests to do
  anything with the cookie, including deletion.

So there you go, another way to blow your foot!

[No back button after logout]: {{ '/2023/04/17/no-back-button/' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[Mojolicious]: https://metacpan.org/pod/Mojolicious
[curl]: https://curl.se/
