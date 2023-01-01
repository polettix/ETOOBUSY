---
title: 'Log::Log4perl::Tiny update'
type: post
tags: [ perl ]
comment: true
date: 2022-03-20 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I'm updating [Log::Log4perl::Tiny][] to fix a bug.

Back in 2010 I decided to clean up some code that I had been using for
logging. It was inspired to the interface of the venerable
[Log::Log4perl][]. I liked that module a lot, but it included a lot of
stuff inside and at that time I often needed to pack standalone programs
with all batteries inside, so a one-file module was ideal.

That led to [Log::Log4perl::Tiny][]. It tries to follow the bigger
module as much as possible, while providing a couple of extensions of
its own.

It seems that some people found it useful in time, and took the burden
to report bugs as they were found. Yay free software!

The latest one reported is [this issue][], by [JC001010][]. In short,
it's possible to intermix text parts in the messages to log with sub
references, which will be called "just in time" and only if really
needed (i.e. if the message has to be logged according to the current
logging level setup). This allows skipping costly operations, like
dumping data structures while debugging, because it would allow to
encapsulate the costly operations in a sub reference, like this:

```perl
DEBUG 'the data structure is ', sub { Data::Dumper::Dumper($data) };
```

If the log level is `INFO` or above, nothing is printed by the above
line and, more importantly, the dumping function is *not* called.

So well, yes, that had a problem. Some of the provided methods/functions
allow using *both* the machinery that comes with [Perl][] (like `die`,
`warn`, or the stuff in [Carp][]) and the one shipped with the module.
Fact is that the message parts were not properly expanded in these
cases, leading to some confusing messages with strange `CODE` strings
inside. Whoops!

I uploaded a hopefully fixing [trial release 1.4.1][] to CPAN, let's see
how it goes with the [CPANTesters][] and then I'll do an official
release.

Thanks [Perl][] community!

[Perl]: https://www.perl.org/
[Log::Log4perl::Tiny]: https://metacpan.org/pod/Log::Log4perl::Tiny
[Log::Log4perl]: https://metacpan.org/pod/Log::Log4perl
[this issue]: https://github.com/polettix/Log-Log4perl-Tiny/issues/12
[JC001010]: https://github.com/JC001010
[Carp]: https://metacpan.org/pod/Carp
[trial release 1.4.1]: https://metacpan.org/release/POLETTIX/Log-Log4perl-Tiny-1.4.1-TRIAL
[CPANTesters]: http://matrix.cpantesters.org/?dist=Log-Log4perl-Tiny+1.4.1-TRIAL
