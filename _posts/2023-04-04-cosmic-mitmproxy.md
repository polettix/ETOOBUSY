---
title: Cosmic mitmproxy
type: post
tags: [ mitm, security, mitmproxy ]
comment: true
date: 2023-04-04 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [mitmproxy][] is really useful.

It was a busy, dark night and I needed to closely monitor *all* outcoming
requests from the browser, for later inspection. Nothing really fancy, just
get a list of all URLs at the end of the observation period, to skim through
with `grep` and the like.

My first thought was: *Surely Firefox's developer tools will help me with
this!*. Well... sort of:

- tracking all requests: *check*
- saving to file: *check*
- saving just a list of URLs: **nope**

The interface supports some slicing and dicing, but when it comes to
selecting the multiple interactions that I'm interested into... it's not
possible. I can only select one at a time.

Moreover, I really don't need to get the whole of the traffic. At this
initial stage, I'm just interested into the *URLs*.

OK, next I thought: *Surely Firefox has an extension for this!*. Well...
sort of. It seems that someone needed to do something similar to the
tracking I'm after, produced some code and made it work. They didn't want to
do a complete and slick release, though, so we're left with a dubious
extension that I don't even know if it's really related to the initial hack.

Now this started to get interesting, so I looked around and the internet
reminded be about [mitmproxy][]. Sure, it's a bit *invasive* (one might even
say *overkill*), but it's a fantastic tool and it's perfect for hitting
nails like these.

As I have full control over the browser, I managed to use it in its basic
mode of operation. This meant:

- Run `mitmdump` with the right level of verbosity to extract the full URLs:

```
$ mitmdump --flow-detail=2 --showhost
```

- Set Firefox to use it as a proxy, pointing to `localhost:8080`. Firefox
  keeps proxy configurations by itself, so it's a single-application
  modification.

- Install the certificate in Firefox. In my system, it uses its own set of
  trusted Certification Authorities, so there was no need to install it on
  the whole system.

The last step **MUST NOT** be taken lightly. Always doubt about trusting
those little certificates, right? It helps to use a browser that you can
dedicate to the experiment, so that you can later throw it away and keep
your configuration modifications to a minimum, just to keep the right level
of paranoia.

The tool is really slick. One single nitpick I have is that the verbosity
level 1 (that is `--flow-detail=1`) would be perfect if URLs were complete
and not truncated. So I had to go to the next level and get *much more* than
I really needed.

*Why truncate the URLs in a tool like this... **why?!?***

Well, I guess there's a good reason and I'm just not getting it without
reading around.

In the meantime, stay safe and keep an eye on the *man in the middle!*

[mitmproxy]: https://mitmproxy.org/
