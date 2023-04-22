---
title: Tracciatore - starting point
type: post
tags: [ web, perl, tracking ]
comment: true
date: 2023-04-24 06:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Tracciatore][] is available and can be used as a template/starting point.

I'm slowly advancing in the data collection *thinghie* (last time I wrote
about it in [Data collection update][]).

The code I wrote so far is available in [tracciatore][].

It's mostly *boilerplate* at the moment, not because it does not have
anything, but because there's the authentication apparatus, being able to
rely upon Postgresql and SQLite depending on the environment, and so on. For
this reason, the status as of [skf-candidate][] can be of more general
interest, as it contains this scaffolding which might be adapted to other
purposes with minimal changes (mainly in the naming of things).

As the tag suggests, I'm planning on turning this into a proper minting
module for [skfold][] (much like [A skfold module for Mojolicious applications][]).

Cheers!

[Data collection update]: {{ '/2023/04/15/data-collection-update/' | prepend: site.baseurl }}
[Perl]: https://www.perl.org/
[tracciatore]: https://codeberg.org/polettix/tracciatore
[skf-candidate]: https://codeberg.org/polettix/tracciatore/src/tag/skf-candidate
[A skfold module for Mojolicious applications]: {{ '/2022/06/24/skfold-module-mojo/' | prepend: site.baseurl }}
[skfold]: https://etoobusy.polettix.it/2020/06/22/skfold-simple-files/
