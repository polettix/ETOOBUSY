---
title: OATH Toolkit
type: post
tags: [ security, oath ]
comment: true
date: 2022-06-28 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I found out about the [OATH Toolkit][].

In recent post [Two-factors authentication with OpenSSH][] I talked
about setting 2FA using [google-authenticator-libpam][].

> It now occurs to me that I didn't mention or link that in my previous
> post. Ooops.

Afterwards, I discovered the [OATH Toolkit][] and soon realized that it
*too* has a PAM module. Here's what I found **so far**:

- it seems that nobody cared to do a comparison between the two. Most
  tutorial I found around are sticking to
  [google-authenticator-libpam][] but it *might* be that it's for the
  same reason I also did that: I just found out about it much more
  easily. I'd love to see a comparison from people that used both and
  have the knowledge to say something about their experience.

- the [OATH Toolkit][] is a... *toolkit* and this can be very useful to
  implement additional use cases. On the other hand it's a... *toolkit*,
  so those additional use cases will have to be implemented, with all
  the associated risks of blowing up the result.

- *en-passant*, I also discovered that there are a couple of [CPAN][]
  modules to help with OATH stuff... like [App::OATH][] and
  [Authen::OATH][], which are worth investigating.

Well, there will be stuff to read... stay *secure* everybody!

[Two-factors authentication with OpenSSH]: {{ '/2022/06/26/ssh-2fa/' | prepend: site.baseurl }}
[google-authenticator-libpam]: https://github.com/google/google-authenticator-libpam
[Perl]: https://www.perl.org/
[CPAN]: https://metacpan.org/
[App::OATH]: https://metacpan.org/pod/App::OATH
[Authen::OATH]: https://metacpan.org/pod/Authen::OATH.
[OATH Toolkit]: https://gitlab.com/oath-toolkit/oath-toolkit
