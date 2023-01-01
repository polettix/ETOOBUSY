---
title: 'Getopt::Long long options are case-insensitive'
type: post
tags: [ perl ]
comment: true
date: 2022-05-08 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Getopt::Long][] is case-insensitive when acception options 

Which is something that surprised me a bit, although it's in the
documentation (emphasys added by me):

> When configured for bundling, single-character options are matched
> case sensitive while **long options are matched case insensitive**.

I'm not sure why the choice, but it seems that it's there and there's
nothing to do about it.

This allowed me to discover that I had a bug in [teepee][] up to a few
days ago, when I realized the error and corrected it. I never really hit
it because I use short options when I need it.

And yes, this is my public shaming for not testing my stuff
properly/thoroughly.

Stay safe!

[Perl]: https://www.perl.org/
[teepee]: {{ '/2021/03/16/teepee/' | prepend: site.baseurl }}
[Getopt::Long]: https://metacpan.org/pod/Getopt::Long
