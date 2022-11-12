---
title: 'unit sub MAIN (...);'
type: post
tags: [ rakulang ]
comment: true
date: 2021-08-27 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I discovered `unit sub MAIN (...);` and I like it.

I read [Mark Gardner][mgardner]'s [Frenemies part 2: What a difference a
(Perl) module makes][initial-article] (which I suggest people to read,
too) and I was intrigued by this comment by Mark J. Reed:

> For short programs with no other subroutines, I prefer using `unit sub
> MAIN(signature here);`, which treats the entire file as the body of
> the MAIN subroutine and saves you some curlies and an indentation
> level while still getting you the automatic argument parsing that
> comes from declaring a MAIN sub.

Indeed this is a nice way of getting out-of-the-box command line
handling for simple (and *not-so-simple* maybe?) programs:

```raku
#!/usr/bin/env raku
use v6;
unit sub MAIN (:$this!, :$that = 'whatever');

put "this<$this>";
put "that<$that>";
```

It's the good ol' bunch of lines likely to grow untamed, which has a
retro feeling I like at my age.

But then *this* caught my attention (emphasis mine):

> For short programs **with no other subroutines**, I prefer [...]

*Wait, what*?

This restriction can be loosened a bit. [Raku][] allows having subs
nested in other subs, so this works too:

```raku
#!/usr/bin/env raku
use v6;
unit sub MAIN (:$this!, :$that = 'whatever');

put "this<$this>";
put "that<$that>";

print-all($this, $that);

sub print-all (*@stuff) { .put for @stuff }
```

Then... of course there will probably be *differences* (like... *does
`print-all` have a fully qualified name at all?*), but again this means
that for *simple* programs it's still possible to get organized with
some modularity.

Alas, at the expense of that retro feeling. *I'm getting too old for
this...*

Have `-Ofun` and stay safe people!!!

[Raku]: https://www.raku.org/
[comment]: https://phoenixtrap.com/2021/08/24/frenemies-part-2-what-a-difference-a-perl-module-makes/#comment-357
[initial-article]: https://phoenixtrap.com/2021/08/24/frenemies-part-2-what-a-difference-a-perl-module-makes/
[mgardner]: https://phoenixtrap.com/
