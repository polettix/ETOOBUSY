---
title: PWC171 - First-class Function
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-06-30 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#171][].
> Enjoy!

# The challenge

> Create `sub compose($f, $g)` which takes in two parameters `$f` and
> `$g` as subroutine refs and returns subroutine ref i.e. `compose($f,
> $g)->($x) = $f->($g->($x))`
>
> e.g.
>
>     $f = (one or more parameters function)
>     $g = (one or more parameters function)
>
>     $h = compose($f, $g)
>     $f->($g->($x,$y, ..)) == $h->($x, $y, ..) for any $x, $y, ...

# The questions

I know I should pepper this specific task with tests... but can we please
pretend I did just for asking here?

Also, this is somehow weird in the light of how broad the PWC audience
is... it seems very skewed towards [Perl][]. It this by intention?

More interestingly, can we assume that the `$g` function should be
called in list context, and that the user knows that `compose` should be
called in the same context as `$f`?

# The solution

In an effort at being minimalistic, this is my solution in [Perl][]:

```perl
sub compose ($f, $g) { sub { $f->($g->(@_)) } }
```

I assume this is right, until proven wrong. It's so short that any
[Perl][] master will probably debunk it with just a glance.

I'm *not so sure* about the [Raku][] alternative though, I feel like
there's so much more to it and so many corner cases. Which, I have to
admit, do not really add to the whipuptitude.

```raku
sub compose (&f, &g) { sub {f(g(@_))} }
```

Again, I hope some [Raku][] master will be so benevolent as to take a
look and point out at least the most grandiose errors with this.

All in all, I guess [manwar][] tried to start something with this
challenge.

[The Weekly Challenge]: https://theweeklychallenge.org/
[#171]: https://theweeklychallenge.org/blog/perl-weekly-challenge-171/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-171/#TASK2
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[manwar]: http://www.manwar.org/
