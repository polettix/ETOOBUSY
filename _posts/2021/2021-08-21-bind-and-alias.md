---
title: Bind and alias
type: post
tags: [ perl, rakulang ]
comment: true
date: 2021-08-21 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> Of course I had to look into some way of doing *binding* in [Perl][]
> too.

In previous post [PWC126 - Minesweeper Game][] I used a binding to
work on a matrix row, like this:

```raku
my @row := @field[$ri];
```

and eventually observed:

> I guess that something similar can be done with [Perl][] too… but I’m
> happy like this!

*Of course* that last statement was a lie, so I went on to look for it.

The first thing that I looked at is [Data::Alias][]:

> Data::Alias - Comprehensive set of aliasing operations
>
> ...
>
> ```perl
> use Data::Alias;
> ...
> alias @x = @y; # alias @x to @y
> ```

Seems spot on! Until I read this in the admittedly excellent
documentation:

> Perl 5.22 added some support for aliasing to the Perl core. It has a
> different syntax, and a different set of operations, from that
> supplied by this module; see ["Assigning to References" in
> perlref][assigning]. The core's aliasing facilities are implemented
> more robustly than this module and are better supported. If you can
> rely on having a sufficiently recent Perl version, you should prefer
> to use the core facility rather than use this module. If you are
> already using this module and are now using a sufficiently recent
> Perl, you should attempt to migrate to the core facility.

Very well then... I plan on using nothing older than the already-old
version `v5.24`, so let's skip [Data::Alias][] and move on to [the
*official* core way of doing this][assigning]:

```perl
use feature 'refaliasing';
no warnings 'experimental::refaliasing';
...
\my @row = $field[$ri];
```

**This** is the way of doing the binding. Ehr, the aliasing. Whatever.

> I'm not talking from a phylosophical standpoint — of course there
> might be a ton of subtleties where this is *different* from binding in
> [Raku][] — but from the point of view of an *unsophisticated*
> programmer this is how we can obtain the same result.

**Now** *I'm happy like this*! Stay safe and have fun folks!

[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[PWC126 - Minesweeper Game]: {{ '/2021/08/19/pwc126-minesweeper-game/' | prepend: site.baseurl }}
[Data::Alias]: https://metacpan.org/pod/Data::Alias
[assigning]: https://metacpan.org/pod/perlref#Assigning-to-References
