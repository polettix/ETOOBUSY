---
title: 'Data::Resolver on Codeberg'
type: post
tags: [ perl ]
comment: true
date: 2023-01-30 07:00:00 +0100
mathjax: false
published: true
---

**TL;DR**

> I put [Data-Resolver][] on Codeberg.

In my effort to evolve [pdfunnel][] in some extensible way, I took a
detour with [Turn this into that][] to land on [Data-Resolver][].

The underlying idea is to define a basic API for turning a key into a
value/file/filehandle, depending on the specific need. More, the data
might come from the filesystem, from a tar file, from... basically
whatever.

The interface is just a code reference, which accepts a mandatory *key*
as the first argument, and an optional *type* as the second argument.
When providing a key, the corresponding value is returned, possibly
honoring the requested type among `data`, `file` and `filehandle`.

This should allow getting the right thing for most of the modules
around, which sometimes accept filehandles, other times straight data
etc.

There's a *little* overloading of the interface by passing `undef` as
first argument and the string `list` as the second - it is supposed to
provide a list of all accessible keys. Some resolvers might also support
getting a list for *sub directories*, if it makes sense; it's not
mandatory though.

I still have to write docs for it, so for the time being the curious
folk will have to take a look at [the tests][].

[Perl]: https://www.perl.org/
[Data-Resolver]: https://codeberg.org/polettix/Data-Resolver
[Turn this into that]: {{ '/2023/01/25/turn-this-in-that/' | prepend: site.baseurl }}
[pdfunnel]: {{ '/2022/11/09/pdfunnel/' | prepend: site.baseurl }}
[the tests]: https://codeberg.org/polettix/Data-Resolver/src/branch/main/t
