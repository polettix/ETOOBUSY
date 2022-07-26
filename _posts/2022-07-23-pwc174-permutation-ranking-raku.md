---
title: PWC174 - Permutation Ranking (Raku)
type: post
tags: [ the weekly challenge ]
comment: true
date: 2022-07-23 07:00:00 +0200
mathjax: true
published: true
---

**TL;DR**

> On with [TASK #2][] from [The Weekly Challenge][] [#174][].
> Enjoy the [Raku][] solution!

In previous post [PWC174 - Permutation Ranking][] I had to go *very
fast* to push the post in time - the [Codeberg][]-backed alternative of
the post went online just a few seconds before midnight, so I'll call it
a day.

We were left with the questions sections and the [Raku][] solution
though, so here we go!

# The questions

My first question is about the ordering that's been chosen.
*Lexicographic, really?!?* I mean, we're dealing with integers here, why
not the plain old ordering for integers?

I wonder how many solutions provide the right rank for input
`[ 111, 22, 3 ]`! (I say it's 0).

Which brings us directly to the other question: integers, right? Not
necessarily one-digit non-negative integers, but integers right?

This, in turn, begs the question about the ordering of single digits but
most of all whether the negative sign should be considered to come
before or after the digits. I'll assume yes because both ASCII and
EBCDIC have this, but I'm not entirely sure that collation and sorting
for different languages around the world actually honor this.

# The solution (in Raku)

So, [Raku][] at last!

```raku
#!/usr/bin/env raku
use v6;
sub MAIN {
   say permutation2rank([< a b c d >]);
   say permutation2rank([< 111 22 3 >]);
   say rank2permutation([ 0, 1, 2 ], 1);
}

sub permutation2rank (@permutation) {
   my $n = @permutation;
   my @baseline = @permutation.sort({$^a.Str cmp $^b.Str});
   my $factor = [*] 1 .. $n;
   (0 .. $n - 2).map({
      my $target = @permutation[$_];
      my $index = 0;
      ++$index while @baseline[$index] ne $target;
      @baseline.splice($index, 1);
      ($factor /= $n - $_) * $index;
   }).sum;
}

sub rank2permutation (@baseline is copy, $r is copy) {
   my $n = @baseline;
   my $factor = [*] 1 ..^ $n;
   return [
      (0 ..^ $n).map({
         my $index = $r div $factor;
         $r %= $factor;
         $factor div= ($n - 1 - $_) if $factor > 1;
         @baseline.splice($index, 1).Slip;
      })
   ];
}
```

Nothing really fancy, just a translation from the [Perl][] code.

Stay safe!

[Raku]: https://www.raku.org/
[Perl]: https://www.perl.org/
[The Weekly Challenge]: https://theweeklychallenge.org/
[#174]: https://theweeklychallenge.org/blog/perl-weekly-challenge-174/
[TASK #2]: https://theweeklychallenge.org/blog/perl-weekly-challenge-174/#TASK2
[Codeberg]: https://www.codeberg.org/
[PWC174 - Permutation Ranking]: {{ '/2022/07/22/pwc175-permutation-ranking/' | prepend: site.baseurl }}
