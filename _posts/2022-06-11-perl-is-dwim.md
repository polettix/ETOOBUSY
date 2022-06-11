---
title: Perl is DWIM
type: post
tags: [ perl ]
comment: true
date: 2022-06-11 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I forgot about some batteries included with [Perl][].

In previous post [Dew - running a command, lazily][] I described a
loooong way to run a command using the shell:

```perl
system {'/bin/sh`} '/bin/sh`, `-c`, $command;
```

This is a *complex* way of invoking `system` (which also exists for
`exec`, by the way), the simpler being:

```
system $command;
```

I never use this simpler form, because it passes `$command` to the shell
for interpretation.

*Right.*

**WAIT A MINUTE!**

This is exactly what I was after in the first place, so this was *that
one time* in which my muscle memory failed me, and my normal memory too
(letting me forget that [Perl][] is very *do what I mean* in nature).

I'm still leaving the implementation as-is anyway. It will be a clear
sign for future me that this is exactly what I'm after, and not
something that slipped for being in a hurry and left as a potential
liability.

Of course I couldn't figure this out all on my own, so I'm very, very
happy (and lucky!) that [wiser people][apag] take a look at my ramblings
and gift me with their time to leave [a feedback][]:

![AP feedback]({{ '/assets/images/20220610-feedback.png' | prepend: site.baseurl }})

Stay safe!

[Perl]: https://www.perl.org/
[Dew - running a command, lazily]: {{ '/2022/06/10/dew-run-command/' | prepend: site.baseurl }}
[apag]: https://twitter.com/apag
[a feedback]: https://twitter.com/apag/status/1535608529083584516
