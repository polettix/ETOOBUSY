---
title: Idiomatic corrections
type: post
tags: [ rakulang, learning ]
comment: true
date: 2021-08-08 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> [gfldex][] gently provided a more idiomatic approach to [Double check
> a puzzle result][]

Sadly... under the assumption that I would have *understood* it.

First things first, read [Only infinite elements][]. This is *how*
[Double check a puzzle result][] should have been coded in an
*idiomatic* way.

I'm in that stage where I honestly have a strong [Perl][] accent (which
I like anyway, as I love [Perl][]) and I can't fully understand people
that talk *too strict*.

For example, I can probably *guess* what this is for:

```raku
(1..6).roll(*)
```

but I don't know how to correctly *read* it. Is it something like *take
this list and apply the `roll` whatever times you need*? If so, why is
the *whatever* an argument to [`roll`][]?

Which, of course, led me to this in the documentation:

```raku
multi method roll($n --> Seq)
```

How nice! So whenever there's an argument, I can put a *whatever* and
this will generate an infinite lazy list! Let's put it to the test:

```
$ raku
...
> sub prova ($n) { return 1 .. $n }
&prova
> my $s = prova(*)
1..Inf
```

*Oooooh!*

As a nice side effect, I also got to learn a couple additional things:

- there's [`roll`][] and there's [`pick`][]. In a nutshell, the former
  just takes values at random and they might be duplicated, while the
  latter will only give back distinct elements in a single call.
- [Andrew Shitov][] wrote a couple of articles on them, [🔬 44.
  Exploring the pick and the roll methods in Raku, part 1][as1],
  [🔬45. Exploring the pick and the roll methods in Raku, part 2][as2],
  and [🔬46. How does ‘pick’ return unique elements (Exploring the pick and the roll methods in Raku, part 3)][as3].

Time to read something!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Double check a puzzle result]: {{ '/2021/08/02/double-check-puzzle-result/' | prepend: site.baseurl }}
[gfldex]: https://gfldex.wordpress.com/
[Only infinite elements]: https://gfldex.wordpress.com/2021/08/02/only-infinite-elements/
[`roll`]: https://docs.raku.org/routine/roll
[`pick`]: https://docs.raku.org/routine/pick
[as1]: https://andrewshitov.com/2018/02/02/exploring-the-pick-and-roll-methods-in-perl-6-part-1/
[as2]: https://andrewshitov.com/2018/02/03/45-exploring-the-pick-and-the-roll-methods-in-perl-6-part-2/
[Andrew Shitov]: https://andrewshitov.com/
[as3]: https://andrewshitov.com/2018/02/04/46-exploring-the-pick-and-the-roll-methods-in-perl-6-part-3/
