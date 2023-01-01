---
title: "Disarium Numbers: brute force won't cut it"
type: post
tags: [ the weekly challenge, anticipation ]
comment: true
date: 2022-07-20 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> A brute force attack to the [Disarium Numbers][] challenge did not
> work for me.

My routine for [The Weekly Challenge][] is to attack the first one in
*[Raku][] then [Perl][]* order and the second one the other way around.

My approach is also to use brute force whenever possible, even though I
*feel* that there might be more to it. There's an interesting internal
tension between the more *scientific* part that would like to know more,
and the more *engineering* part that just wants to get the job done with
as few resources as possible (I mean, my resources).

So this time I went for the usual way and wrote a very basic brute-force
solution in [Raku][]:

```raku
#!/usr/bin/env raku
use v6;
sub MAIN (Int:D $n where * > 0 = 19) {
   my $candidate = 0;
   my $i = 0;
   while $i < $n {
      if is-disarium($candidate) {
         "\%0{$n.chars()}d. %d".sprintf(++$i, $candidate).put;
      }
      ++$candidate;
   }
}

sub is-disarium (Int:D $n where $n >= 0) {
   $n == $n.comb.kv.map(-> $x, $y { $y ** ($x + 1) }).sum;
}
```

Curiously, it took me *ages* to get the `map` right, first because I
initially used `pairs` instead of `kv`, which put me incredibly close to
the event horizon of a black hole from where I would have never escaped
(except, possibly, as Hawking radiation), and second because I was
insisting on round parentheses around `$x, $y`, which are not needed
when using `->`. Ouch.

This program gets the first **18** [Disarium Numbers][] pretty quickly,
but it takes ages for the **19th**. Which is needed to complete the
challenge.

So yes, the code above will find the requested solution... *eventually*.
Yet it takes too much to accept it, even by *engineering* standards.

I'll leave with a final note about the need for exactly 19 members of
the [Disarium Numbers][] 20-members family. I mean, that's being *mean*
in two senses:

- the 19th member is considerably greater than the first 18, which means
  that brute-force approaches will suffer (at least in languages that
  have margins for optimization);
- the 20th member *feels excluded*. I mean, it's the last one and
  there's no other after, why leave it outside in the cold? Or, well, in
  the heat, if you're in Roma these times?

See you next time!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[Disarium Numbers]: https://theweeklychallenge.org/blog/perl-weekly-challenge-174/#TASK1
[The Weekly Challenge]: https://theweeklychallenge.org/
