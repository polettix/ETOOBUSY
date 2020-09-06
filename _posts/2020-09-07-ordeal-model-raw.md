---
title: 'Ordeal::Model gets a Raw backend'
type: post
tags: [ perl, board game ]
comment: true
date: 2020-09-07 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [Ordeal::Model][]'s new release got an additional *Raw* backend.

[Ordeal::Model][] is a [Perl][] module that basically serves the needs of
[ordeal][], a small semi-public web application to randomly draw *cards*. Well,
also die faces, if you think about a six-faced die as a deck of six cards where
you only deal one at any time.

Up to now, the only *backend* for defining cards was file-based (with
a YAML-based extension). It never really got me happy because I wanted
something *more general*.

This is where [Ordeal::Model::Backend::Raw][] comes into play.

It accepts a hash reference with the following YAMLish example structure:

```YAML
cards:
   - id: d3-1
     data: this is face 1
     content-type: text/plain
   - id: d3-2
     data: this is face 2
     content-type: text/plain
   - id: d3-3
     data: this is face 3
     content-type: text/plain
decks:
   - id: d3
     cards: [ d3-1 d3-2 d3-3 ]
   - id: loaded-d3
     cards: [ d3-1 d3-2 d3-3 d3-3 ]
```

One way this is useful is for building decks/dice out of images that are
not necessarily stored in [ordeal][]:

```YAML
cards:
   - id: d3-1
     data: https://example.com/d3/1.png
     content-type: text/plain
   - id: d3-2
     data: https://example.com/d3/1.png
     content-type: text/plain
   - id: d3-3
     data: https://example.com/d3/1.png
     content-type: text/plain
decks:
   - id: d3
     cards: [ d3-1 d3-2 d3-3 ]
   - id: loaded-d3
     cards: [ d3-1 d3-2 d3-3 d3-3 ]
```

I know that we can do better with the Content-Type... but you get the
idea.

So, now [Ordeal::Model][] really lets us shuffle... whatever.


[Ordeal::Model]: https://metacpan.org/pod/Ordeal::Model
[Ordeal::Model::Backend::Raw]: https://metacpan.org/pod/Ordeal::Model::Backend::Raw
[ordeal]: https://ordeal.introm.it/
[Perl]: https://www.perl.org/
