---
title: 'Raku cglib: a priority queue'
type: post
tags: [ raku, perl, cglib ]
comment: true
date: 2021-06-27 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> The first implementation in [cglib-raku][]: [PriorityQueue.rakumod][]!

My first stab at adding something to [cglib-raku][] was porting the
[PriorityQueue.pm][] [Perl][] module.

The porting in [PriorityQueue.rakumod][] is pretty much a *translation*,
although of course the two languages are different and even more so in
their handling of OO coding.

I have to admit that getting used to the [Raku][] way of doing OO was
easy, thanks to [Moose][] (as a movement) and to [Moo][] (which I like
to use, although not in [cglib-perl][]).

The original [PriorityQueue.pm][] was coded with *bare bones* OO in
[Perl][]: keeping stuff in an anonymous hash and `bless`ing it.
Admittedly, this and my goal to be as compact as possible (optimizing
for cut-and-paste in [CodinGame][]!) make the [Perl][] implementation
quite *difficult* to read, but this is no more the case in [Raku][] in
my opinion.

I liked the possibility to define and use *private* methods instead of
relying upon the *convention* to pre-pend these methods with an
underscore, as well as being able to easily avoid some of the "Perl
line noise" constructs. Example:

```
# Perl
$self->_adjust($k) if $k <= $#$is;

# Raku
self!adjust($k) if $k <= @!items.end;
```

Although I generally like the *huffmanization* that happened in
[Perl][], I have to admit that I like using `@array.end` a bit better
(easier on the eyes I guess). Still, a matter of taste I guess.

Using twigils is a bit overwhelming, and in the first pass of the
porting I easily forgot about one half of them. All in all, anyway, I
think they make sense and I hope I'll get up to speed with them shortly.

All in all, I liked doing the porting and using the *batteries included,
language provided* OO machinery was really refreshing.

At this point, I really hope that [Corinna][] (well, whatever it will
evolve into anyway) will make its way into the [Perl][] core. I can
agree that `bless` and `@ISA` are a genius hack that allowed introducing
an effective OO "style" with very little, but I also think that *a
contemporary general-purpose language should include production-grade
OO as a first-class citizen*.


[cglib-raku]: https://github.com/polettix/cglib-raku
[cglib-perl]: https://github.com/polettix/cglib-perl
[PriorityQueue.rakumod]:  https://github.com/polettix/cglib-raku/blob/master/PriorityQueue.rakumod
[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[PriorityQueue.pm]:  https://github.com/polettix/cglib-perl/blob/master/PriorityQueue.pm
[Moose]: https://metacpan.org/pod/Moose
[Moo]: https://metacpan.org/pod/Moo
[CodinGame]: https://www.codingame.com/
[Corinna]: https://github.com/Ovid/Cor/wiki/Proposed-RFC
