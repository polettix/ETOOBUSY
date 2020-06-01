---
title: Publishing time for busypub
type: post
tags: [ blog, perl, coding ]
comment: true
date: 2020-06-06 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Publishing posts at 2 AM isn't exactly efficient.

In [ETOOBUSY automated publishing][] we took a look at [busypub][], a
small program to automate the process so that I can prepare posts
beforehand and let the system publish one per day.

Then, in [Notifications for busypub][], we went a little step ahead to
auto-announce the publishing on [Mastodon][] and [Twitter][]. Which
*really* frees me up from the publishing process, because that was the
missing piece. Now, I only have to make sure that a post was properly
published.

The initial [busypub][] was programmed to publish at midnight, as soon
as the new day becomes reality. As the time zone in the containers for
[Dokku][] defaults to `UTC+0000`, this means that - for me - the
publishing process currently happens at 2 AM.

I don't disillude myself about writing something *interesting*, but I
can at least make sure that my notifications happen in line with my time
zone. For this reason, as of [commit 4c1ba2b][], it's possible to set
the publishing time and a timezone with two additional environment
variables:

- `TIMEZONE`: this allows controlling the timezone from *within* the
  process, although it would probably work just as well by setting `TZ`
  directly;
- `PUBLISH_TIME`: when posts should be published, defaults to
  `07:00:00`. You can specify just the hour, hour and minutes, or up to
  the seconds; just separate them with colons.

I hope it will be useful in the future! Well... to me at least 🙄

[ETOOBUSY]: https://github.polettix.it/ETOOBUSY/
[ETOOBUSY automated publishing]: {{ '/2020/05/29/busypub'| prepend: site.baseurl }}
[busypub]: https://github.com/polettix/busypub
[Perl]: https://www.perl.org/
[Notifications for busypub]: {{ '/2020/06-02/busypub-notifications'| prepend: site.baseurl }}
[Mastodon]: https://mastodon.social/
[Twitter]: https://twitter.com/
[Dokku]: http://dokku.viewdocs.io/dokku/
[commit 4c1ba2b]: https://github.com/polettix/busypub/commit/4c1ba2b8fa4f8274228ef76ae476b1042673b857
