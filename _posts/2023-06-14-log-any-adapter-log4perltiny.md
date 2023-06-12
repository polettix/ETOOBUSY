---
title: 'Log::Any::Adapter::Log4perlTiny'
type: post
tags: [ perl, module ]
comment: true
date: 2023-06-14 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> First release of [Log::Any::Adapter::Log4perlTiny][].

I think that [Log::Any][] is a brilliant idea and I love
[Log::Log4perl::Tiny][] because it does what I need.

So it was just a matter of time.

Eventually, I resolved to write [Log::Any::Adapter::Log4perlTiny][]; it was
easy, thanks to [Log::Any][]'s minimal yet complete interface.

There's no support for *categories*, by design; also,
[Log::Log4perl::Tiny][] requires no initialization (it comes with what I
consider sensible defaults), so using the new module is as easy as:

```perl
use Log::Any::Adapter 'Log4perlTiny';
use Log::Log4perl::Tiny;
```

It's important to *also* `use` [Log::Log4perl::Tiny][], because the new
module does `use` it, but not in a way that would *activate* it. So... let's
just do it.

I hope it will be useful for you too!

[Perl]: https://www.perl.org/
[Log::Any::Adapter::Log4perlTiny]: https://metacpan.org/pod/Log::Any::Adapter::Log4perlTiny
[Log::Any]: https://metacpan.org/pod/Log::Any
[Log::Log4perl::Tiny]: https://metacpan.org/pod/Log::Log4perl::Tiny
