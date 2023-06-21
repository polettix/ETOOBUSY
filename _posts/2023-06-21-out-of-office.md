---
title: Out of Office
type: post
tags: [ microsoft, office, authentication, security ]
comment: true
date: 2023-06-21 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Make sure **SSL** is off and **recent TLS** is on.

If you resume a very old Windows system and decide to give it a try, you
might have that kind of feeling of how people lived in the past. Well, a few
years ago, at least, which almost surely includes *you* as a
probably-not-so-young reader of this blog (yes, I'm looking at you, future
me!).

You try to start common Microsoft Office programs with an account that has
the right licenses and... nothing, they will not let you in. *Teams* refuses
to comply, suggesting to *Retry*, giving a cryptic (and often changing)
error code that seems like a digest and telling you *there is a better way
to start Teams...*, only there's no *Force* in this universe. *Outlook* may
or may not start, but even then it refuses to connect, sometimes after
having asked your credentials for 10 times in a row (you throw in the towel
because Einstein would consider you a stupid otherwise, but Outlook won
anyway). *OneDrive* happily stays there wheeling. *Excel* might have a
*Word* or two of complaint, and still you can't get the *PowerPoint*.

> OK, those were very, very bad puns.

Out of the gazillion things that might have gone wrong, it *might* depend on
the SSL/TLS settings.

Want to check? Try this:

- *Start* menu (or whatever they call it today), search for `Internet
  Options` and open it
- go to the `Advanced` tab
- scroll down until you see a list of checkboxes that name `SSL` and `TLS`
- *check* `TLS 1.2` and everything above (if present)
- for good measure, *uncheck* everything below.

The last step might lose you some backwards compatibility, which you can
later restore in case of extreme need (still, [consider the
deprecation][deprecation]).

Every Windows release will have it owns specific sub-list, like e.g. `TLS
1.3` might be missing, included with a notice that it's experimental, or
just included. I think it's fair to check it if present, anyway.

I hope this will help you get back in *Office*, cheers!

[deprecation]: https://datatracker.ietf.org/doc/rfc8996/
