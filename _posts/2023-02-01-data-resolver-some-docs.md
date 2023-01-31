---
title: 'Data::Resolver - some docs'
type: post
tags: [ perl ]
comment: true
date: 2023-02-01 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I started fleshing out docs for [Data-Resolver][].

Straight out of what is already available...

> While coding, two problems often arise:
>
> - Using several modules, there can be a variety of ways on how they
>   get access to data. Many times they support reading from a file, but
>   often times they expect to receive data (e.g.
>   [JSON::PP](https://metacpan.org/pod/JSON%3A%3APP)). Other times
>   modules an be OK with both, and even accept _filehandles_.
> - Deciding on where to store data and what to use as a source can be
>   limiting, especially when multiple _things_ might be needed. What is
>   best at that point? A directory? An archive? A few URLs?
>
> This module aims at providing a way forward to cope for both problems,
> by providing a unified interface that can get three types of _data
> types_ (i.e. `data`, `file`, or `filehandle`) while at the same time
> providing a very basic interface that can be backed by several
> different fetching approaches, like reading from a directory, taking
> items from an archive, or download stuff on the fly from a URL.

More in [the repo][Data-Resolver]!


[Perl]: https://www.perl.org/
[Data-Resolver]: https://codeberg.org/polettix/Data-Resolver
[JSON::PP]: https://metacpan.org/pod/JSON::PP
