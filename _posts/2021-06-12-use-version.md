---
title: use VERSION - but how?
type: post
tags: [ perl ]
comment: true
date: 2021-06-12 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> It's fine to `use v5.X.Y` with the `v` when asking for a minimum
> `perl` version and its related features.

More and more in the past days I read about setting a `use v5.X` or `use
v5.X.Y` line early in [Perl][] programs, just to get all *benefits* of
that specific `perl` version out of the box.

This started to *itch* a bit after some time because in all those places
they were suggesting to use the **v-string** form, i.e. prefixing the
version with the letter `v`. The itch was that I was used to using:

```
use 5.024; # no "v", and a "0" before "24"
```

instead, for reasons that I understood at the time I chose this form,
but that I obviously obliviated on the spot.

So, what's better? It turns out that putting the `v` is, in 2021, mostly
fine. Well, totally fine in my (new) opinion.

From the [use][] documentation:

> Specifying VERSION as a numeric argument of the form 5.024001 should
> generally be avoided as older less readable syntax compared to
> v5.24.1. Before perl 5.8.0 released in 2002 the more verbose numeric
> form was the only supported syntax, which is why you might see it in
>
>     use v5.24.1;    # compile time version check
>     use 5.24.1;     # ditto
>     use 5.024_001;  # ditto; older syntax compatible with perl 5.6

So there you have it, I was using the `5.024` form just to make sure that
some `perl` from middle ages would properly parse it and, *in any case*,
complain that it could not execute it.

Additional elaborations regarding version numbers (although on the
*setting* side, not on the `use`ing side) can be found here: [Version
numbers should be boring][].

Bottom line: it's fine to `use v5.X.Y;` with the `v` to settle for a
minimum `perl` version in 2021.

[use]: https://perldoc.perl.org/functions/use
[Perl]: https://www.perl.org/
[Version numbers should be boring]: https://xdg.me/version-numbers-should-be-boring/
